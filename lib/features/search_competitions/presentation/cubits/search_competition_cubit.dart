import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  static const int _pageSize = 10;

  CompetitionTab _activeTab = CompetitionTab.all;
  String _currentKeyword = '';

  StreamSubscription<List<CompetitionEntity>>? _competitionsSubscription;
  StreamSubscription<List<CompetitionEntity>>? _paginationSubscription;

  CompetitionTab get activeTab => _activeTab;
  String get currentKeyword => _currentKeyword;

  SearchCompetitionCubit({
    required StreamPublicCompetitionsUseCase streamPublicCompetitionsUseCase,
    required StreamSearchCompetitionsUseCase streamSearchCompetitionsUseCase,
    required StreamJoinedCompetitionsUseCase streamJoinedCompetitionsUseCase,
    required StreamCreatedCompetitionsUseCase streamCreatedCompetitionsUseCase,
    required JoinCompetitionSearchUseCase joinCompetitionSearchUseCase,  
  })  : _streamPublicCompetitionsUseCase = streamPublicCompetitionsUseCase,
        _streamSearchCompetitionsUseCase = streamSearchCompetitionsUseCase,
        _streamJoinedCompetitionsUseCase = streamJoinedCompetitionsUseCase,
        _streamCreatedCompetitionsUseCase = streamCreatedCompetitionsUseCase,
        super(SearchCompetitionInitial());

  void changeTab(CompetitionTab tab, {String query = ''}) {
    _activeTab = tab;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  void getPublicCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.all;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  void getJoinedCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.joined;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  void getCreatedCompetitions({String query = ''}) {
    _activeTab = CompetitionTab.created;
    _currentKeyword = query.trim().toLowerCase();
    _listenToCompetitions();
  }

  void search(String keyword) {
    _currentKeyword = keyword.trim().toLowerCase();
    _listenToCompetitions();
  }

  void clearSearch() {
    _currentKeyword = '';
    _listenToCompetitions();
  }

  /// 🚀 Paginate: Loads the next batch without duplicates or infinite loops
  void loadMore() {
    final currentState = state;

    // Check loading flags and prevent simultaneous pagination calls
    if (currentState is! SearchCompetitionSuccess ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    _safeEmit(currentState.copyWith(isLoadingMore: true));

    final lastCompetitionId = currentState.competitions.isNotEmpty
        ? currentState.competitions.last.id
        : null;

    // Cancel any active pagination stream listener before starting a new fetch
    _paginationSubscription?.cancel();

    _paginationSubscription = _executeStream(lastCompetitionId: lastCompetitionId).listen(
      (newCompetitions) {
        // Immediately cancel this single-shot listener so future updates don't append again
        _paginationSubscription?.cancel();

        if (newCompetitions.isEmpty) {
          _safeEmit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          // 1. Filter out items that already exist in state by ID (Deduplication)
          final existingIds = currentState.competitions.map((c) => c.id).toSet();
          final uniqueNewItems = newCompetitions
              .where((c) => !existingIds.contains(c.id))
              .toList();

          // 2. If all fetched items were already in list, treat as max reached to stop loops
          final bool reachedEnd = uniqueNewItems.isEmpty || newCompetitions.length < _pageSize;

          _safeEmit(
            SearchCompetitionSuccess(
              competitions: [
                ...currentState.competitions,
                ...uniqueNewItems,
              ],
              hasReachedMax: reachedEnd,
              isLoadingMore: false,
            ),
          );
        }
      },
      onError: (error) {
        _paginationSubscription?.cancel();
        _safeEmit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  /// Subscribes to the initial batch
  void _listenToCompetitions() {
    _safeEmit(SearchCompetitionLoading());
    _competitionsSubscription?.cancel();
    _paginationSubscription?.cancel();

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

  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    final currentState = state;
    if (currentState is SearchCompetitionSuccess) {
      final updatedList = currentState.competitions.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      _safeEmit(currentState.copyWith(competitions: updatedList));
    }
  }

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

  void _safeEmit(SearchCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    _competitionsSubscription?.cancel();
    _paginationSubscription?.cancel();
    return super.close();
  }
}