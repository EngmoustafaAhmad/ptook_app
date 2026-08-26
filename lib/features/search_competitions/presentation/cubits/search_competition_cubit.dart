import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_created_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_joined_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/get_all_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/join_competition_search_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/stream_search_competitions_usecase.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

part 'search_competition_state.dart';

enum CompetitionTab { all, joined, created }

class SearchCompetitionCubit extends Cubit<SearchCompetitionState> {
  final StreamPublicCompetitionsUseCase _streamPublicCompetitionsUseCase;
  final StreamSearchCompetitionsUseCase _streamSearchCompetitionsUseCase;
  final StreamJoinedCompetitionsUseCase _streamJoinedCompetitionsUseCase;
  final StreamCreatedCompetitionsUseCase _streamCreatedCompetitionsUseCase;
  final JoinCompetitionSearchUseCase _joinCompetitionSearchUseCase;

  static const int _pageSize = 10;
  bool _isFetchingMore = false;

  CompetitionTab _activeTab = CompetitionTab.all;
  String _currentKeyword = '';
  StreamSubscription<List<CompetitionEntity>>? _competitionsSubscription;

  CompetitionTab get activeTab => _activeTab;
  String get currentKeyword => _currentKeyword;

  SearchCompetitionCubit({
    required StreamPublicCompetitionsUseCase streamPublicCompetitionsUseCase,
    required StreamSearchCompetitionsUseCase streamSearchCompetitionsUseCase,
    required StreamJoinedCompetitionsUseCase streamJoinedCompetitionsUseCase,
    required StreamCreatedCompetitionsUseCase streamCreatedCompetitionsUseCase,
    required JoinCompetitionSearchUseCase joinCompetitionSearchUseCase,  
  })  :  _streamPublicCompetitionsUseCase = streamPublicCompetitionsUseCase,
        _streamSearchCompetitionsUseCase = streamSearchCompetitionsUseCase,
        _streamJoinedCompetitionsUseCase = streamJoinedCompetitionsUseCase,
        _streamCreatedCompetitionsUseCase = streamCreatedCompetitionsUseCase,
        _joinCompetitionSearchUseCase = joinCompetitionSearchUseCase,
        super(SearchCompetitionInitial());

  /// 🔄 Changes active tab with an optional search query
  void changeTab(CompetitionTab tab, {String query = ''}) {
    _activeTab = tab;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  /// 🌟 Fetches public competitions ("All" tab)
  void getPublicCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.all;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  /// 👥 Fetches competitions joined by user ("Joined" tab)
  void getJoinedCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.joined;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  /// 👑 Fetches competitions created by user ("My Created" tab)
  void getCreatedCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.created;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  /// 🔎 Searches within the currently active tab
  void search(String keyword) {
    _currentKeyword = keyword.trim().toLowerCase();
    _listenToCompetitions();
  }

  /// 🧹 Clears search keyword and reloads active tab feed
  void clearSearch() {
    _currentKeyword = '';
    _listenToCompetitions();
  }

  /// 🤝 Joins a competition with optimistic updates and rollback handling
  Future<void> joinCompetition({
  required String competitionId,
  required String userId,
  String? joinCode,
}) async {
  // Optimistic local update
  toggleParticipationStatus(competitionId: competitionId, isJoining: true);

  final result = await _joinCompetitionSearchUseCase(
    competitionId: competitionId,
    userId: userId,
    joinCode: joinCode,
  );

  switch (result) {
    case Success():
      // Dynamic live Firestore streams will auto-sync UI state.
      break;
    case Failure(:final message):
      // Roll back optimistic increment on failure
      toggleParticipationStatus(competitionId: competitionId, isJoining: false);
      _safeEmit(SearchCompetitionError(message));
      break;
  }
}

  /// 🚀 Paginate: Loads the next batch (10 items) for ANY active tab
  void loadMore() {
    final currentState = state;

    if (currentState is! SearchCompetitionSuccess ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore ||
        _isFetchingMore) {
      return;
    }

    _isFetchingMore = true;
    _safeEmit(currentState.copyWith(isLoadingMore: true));

    final lastCompetitionId = currentState.competitions.isNotEmpty
        ? currentState.competitions.last.id
        : null;

    final stream = _executeStream(lastCompetitionId: lastCompetitionId);

    late final StreamSubscription<List<CompetitionEntity>> tempSub;
    tempSub = stream.listen(
      (newCompetitions) {
        _isFetchingMore = false;
        tempSub.cancel();

        if (newCompetitions.isEmpty) {
          _safeEmit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          _safeEmit(
            SearchCompetitionSuccess(
              competitions: [
                ...currentState.competitions,
                ...newCompetitions,
              ],
              hasReachedMax: newCompetitions.length < _pageSize,
              isLoadingMore: false,
            ),
          );
        }
      },
      onError: (error) {
        _isFetchingMore = false;
        tempSub.cancel();
        _safeEmit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  /// Subscribes to the live Firestore stream for initial batch
  void _listenToCompetitions() {
    _safeEmit(SearchCompetitionLoading());
    _competitionsSubscription?.cancel();

    _competitionsSubscription = _executeStream().listen(
      (competitions) {
        _safeEmit(
          SearchCompetitionSuccess(
            competitions: competitions,
            hasReachedMax: competitions.length < _pageSize,
          ),
        );
      },
      onError: (error) {
        _safeEmit(SearchCompetitionError(error.toString()));
      },
    );
  }

  /// Query Dispatcher returning Stream<List<CompetitionEntity>>
  Stream<List<CompetitionEntity>> _executeStream({
    String? lastCompetitionId,
  }) {
    final String? queryParam =
        _currentKeyword.isEmpty ? null : _currentKeyword;

    switch (_activeTab) {
      case CompetitionTab.all:
        if (queryParam == null) {
          return _streamPublicCompetitionsUseCase(
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          );
        } else {
          return _streamSearchCompetitionsUseCase(
            query: queryParam,
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          );
        }

      case CompetitionTab.joined:
        return _streamJoinedCompetitionsUseCase(
          query: queryParam,
          limit: _pageSize,
          lastCompetitionId: lastCompetitionId,
        );

      case CompetitionTab.created:
        return _streamCreatedCompetitionsUseCase(
          query: queryParam,
          limit: _pageSize,
          lastCompetitionId: lastCompetitionId,
        );
    }
  }

  /// Updates a single competition in the current list locally
  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    final currentState = state;
    if (currentState is SearchCompetitionSuccess) {
      final updatedList = currentState.competitions.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      _safeEmit(currentState.copyWith(competitions: updatedList));
    }
  }

  /// Toggles or increments/decrements participant counts locally
  void toggleParticipationStatus({
    required String competitionId,
    required bool isJoining,
  }) {
    final currentState = state;
    if (currentState is SearchCompetitionSuccess) {
      final updatedList = currentState.competitions.map((comp) {
        if (comp.id == competitionId) {
          final newCount = isJoining
              ? comp.participantsCount + 1
              : (comp.participantsCount > 0 ? comp.participantsCount - 1 : 0);

          return comp.copyWith(participantsCount: newCount);
        }
        return comp;
      }).toList();

      _safeEmit(currentState.copyWith(competitions: updatedList));
    }
  }

  /// Safe state emitter
  void _safeEmit(SearchCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    _competitionsSubscription?.cancel();
    return super.close();
  }
}