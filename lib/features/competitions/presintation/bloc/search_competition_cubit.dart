import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/get_created_competitions_usecase.dart';
import '../../domain/usecases/get_joined_competitions_usecase.dart';
import '../../domain/usecases/get_public_competitions_usecase.dart';
import '../../domain/usecases/search_public_competitions_usecase.dart';

part 'search_competition_state.dart';

/// Active tab enum for tab-aware state management
enum CompetitionTab { all, joined, created }

class SearchCompetitionCubit extends Cubit<SearchCompetitionState> {
  final GetPublicCompetitionsUseCase _getPublicCompetitionsUseCase;
  final SearchPublicCompetitionsUseCase _searchPublicCompetitionsUseCase;
  final GetJoinedCompetitionsUseCase _getJoinedCompetitionsUseCase;
  final GetCreatedCompetitionsUseCase _getCreatedCompetitionsUseCase;

  static const int _pageSize = 10;
  bool _isFetchingMore = false;

  CompetitionTab _activeTab = CompetitionTab.all;
  String _currentKeyword = '';

  CompetitionTab get activeTab => _activeTab;
  String get currentKeyword => _currentKeyword;

  SearchCompetitionCubit({
    required GetPublicCompetitionsUseCase getPublicCompetitionsUseCase,
    required SearchPublicCompetitionsUseCase searchPublicCompetitionsUseCase,
    required GetJoinedCompetitionsUseCase getJoinedCompetitionsUseCase,
    required GetCreatedCompetitionsUseCase getCreatedCompetitionsUseCase,
  })  : _getPublicCompetitionsUseCase = getPublicCompetitionsUseCase,
        _searchPublicCompetitionsUseCase = searchPublicCompetitionsUseCase,
        _getJoinedCompetitionsUseCase = getJoinedCompetitionsUseCase,
        _getCreatedCompetitionsUseCase = getCreatedCompetitionsUseCase,
        super(SearchCompetitionInitial());

  /// 🔄 Changes active tab with an optional search query
  Future<void> changeTab(CompetitionTab tab, {String query = ''}) async {
    _activeTab = tab;
    _currentKeyword = query.trim().toLowerCase();
    await _fetchInitialBatch();
  }

  /// 🌟 Fetches public competitions ("All" tab)
  Future<void> getPublicCompetitions({String query = ''}) async {
    _activeTab = CompetitionTab.all;
    _currentKeyword = query.trim().toLowerCase();
    await _fetchInitialBatch();
  }

  /// 👥 Fetches competitions joined by user ("Joined" tab)
  Future<void> getJoinedCompetitions({String query = ''}) async {
    _activeTab = CompetitionTab.joined;
    _currentKeyword = query.trim().toLowerCase();
    await _fetchInitialBatch();
  }

  /// 👑 Fetches competitions created by user ("My Created" tab)
  Future<void> getCreatedCompetitions({String query = ''}) async {
    _activeTab = CompetitionTab.created;
    _currentKeyword = query.trim().toLowerCase();
    await _fetchInitialBatch();
  }

  /// 🔎 Searches within the currently active tab
  Future<void> search(String keyword) async {
    _currentKeyword = keyword.trim().toLowerCase();
    await _fetchInitialBatch();
  }

  /// 🧹 Clears search keyword and reloads active tab feed
  Future<void> clearSearch() async {
    _currentKeyword = '';
    await _fetchInitialBatch();
  }

  /// 🚀 Paginate: Loads the next batch (10 items) for ANY active tab
  Future<void> loadMore() async {
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

    final result = await _executeQuery(
      lastCompetitionId: lastCompetitionId,
    );

    _isFetchingMore = false;

    result.fold(
      (failure) {
        _safeEmit(currentState.copyWith(isLoadingMore: false));
      },
      (newCompetitions) {
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
    );
  }

  /// Private helper to load the first batch for current query & tab
  Future<void> _fetchInitialBatch() async {
    _safeEmit(SearchCompetitionLoading());

    final result = await _executeQuery();

    result.fold(
      (failure) => _safeEmit(SearchCompetitionError(failure.message)),
      (competitions) => _safeEmit(
        SearchCompetitionSuccess(
          competitions: competitions,
          hasReachedMax: competitions.length < _pageSize,
        ),
      ),
    );
  }

  /// Query Dispatcher: Directs request to correct Use Case according to active tab
  Future<dynamic> _executeQuery({String? lastCompetitionId}) {
    // If empty string, pass null to UseCases so backend fetches full list
    final String? queryParam =
        _currentKeyword.isEmpty ? null : _currentKeyword;

    switch (_activeTab) {
      case CompetitionTab.all:
        if (queryParam == null) {
          return _getPublicCompetitionsUseCase(
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          );
        } else {
          return _searchPublicCompetitionsUseCase(
            query: queryParam,
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          );
        }

      case CompetitionTab.joined:
        return _getJoinedCompetitionsUseCase(
          query: queryParam, // Passes null when search is empty!
          limit: _pageSize,
          lastCompetitionId: lastCompetitionId,
        );

      case CompetitionTab.created:
        return _getCreatedCompetitionsUseCase(
          query: queryParam, // Passes null when search is empty!
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
}