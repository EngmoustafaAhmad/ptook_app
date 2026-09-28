import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/search_competitions/domain/usecases/search_active_competitions_usecase.dart';
import 'package:ptook/features/search_competitions/domain/usecases/stream_active_competitions_usecase.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
part 'search_competition_state.dart';

enum CompetitionTab { all, joined, created }

extension CompetitionTabX on CompetitionTab {
  CompetitionFilter toFilter() {
    switch (this) {
      case CompetitionTab.all:
        return CompetitionFilter.all;
      case CompetitionTab.joined:
        return CompetitionFilter.joined;
      case CompetitionTab.created:
        return CompetitionFilter.myCreated;
    }
  }
}

class _CacheEntry {
  final CompetitionPage<CompetitionEntity> page;
  final DateTime timestamp;

  _CacheEntry({required this.page}) : timestamp = DateTime.now();

  bool get isValid =>
      DateTime.now().difference(timestamp) < const Duration(seconds: 45);
}

class SearchCompetitionCubit extends Cubit<SearchCompetitionState> {
  final StreamActiveCompetitionsUseCase _streamActiveCompetitionsUseCase;
  final SearchActiveCompetitionsUseCase _searchActiveCompetitionsUseCase;
  final String _currentUserId;

  static const int _pageSize = 10;

  CompetitionTab _activeTab = CompetitionTab.all;
  String _currentKeyword = '';
  CompetitionCursor? _nextCursor;

  final Map<String, CompetitionEntity> _localOverrides = {};
  final Map<String, _CacheEntry> _queryCache = {};

  StreamSubscription<CompetitionPage<CompetitionEntity>>? _streamSubscription;
  Timer? _debounceTimer;
  int _searchRequestToken = 0;

  CompetitionTab get activeTab => _activeTab;
  String get currentKeyword => _currentKeyword;

  SearchCompetitionCubit({
    required StreamActiveCompetitionsUseCase streamActiveCompetitionsUseCase,
    required SearchActiveCompetitionsUseCase searchActiveCompetitionsUseCase,
    required String currentUserId,
  })  : _streamActiveCompetitionsUseCase = streamActiveCompetitionsUseCase,
        _searchActiveCompetitionsUseCase = searchActiveCompetitionsUseCase,
        _currentUserId = currentUserId,
        super(SearchCompetitionInitial()) {
    _fetchInitial();
  }

  String get _cacheKey => '${_activeTab.name}_$_currentKeyword';

  /// Public trigger method to force-fetch or refresh active competitions
  Future<void> fetchCompetitions({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _queryCache.remove(_cacheKey);
    }
    _fetchInitial();
  }

  void changeTab(CompetitionTab tab, {String query = ''}) {
    _debounceTimer?.cancel();
    final formattedQuery = query.trim().toLowerCase();

    if (_activeTab == tab && _currentKeyword == formattedQuery) {
      return;
    }
    _activeTab = tab;
    _currentKeyword = formattedQuery;
    _fetchInitial();
  }

  void search(String keyword) {
    final formattedKeyword = keyword.trim().toLowerCase();
    if (_currentKeyword == formattedKeyword) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _currentKeyword = formattedKeyword;
      _fetchInitial();
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    if (_currentKeyword.isEmpty) return;
    _currentKeyword = '';
    _fetchInitial();
  }

  void _fetchInitial() {
    _searchRequestToken++;
    _cancelStream();
    _nextCursor = null;

    final cachedEntry = _queryCache[_cacheKey];
    if (cachedEntry != null && cachedEntry.isValid) {
      _nextCursor = cachedEntry.page.nextCursor;
      final mergedItems = cachedEntry.page.items
          .map((item) => _localOverrides[item.id] ?? item)
          .toList();

      _safeEmit(
        SearchCompetitionSuccess(
          competitions: mergedItems,
          hasReachedMax: !cachedEntry.page.hasMore,
        ),
      );
      return;
    }

    _safeEmit(SearchCompetitionLoading());

    if (_currentKeyword.isEmpty) {
      _subscribeToActiveStream();
    } else {
      _executeSearchQuery();
    }
  }

  void _subscribeToActiveStream() {
    _streamSubscription = _streamActiveCompetitionsUseCase(
      StreamActiveCompetitionsParams(
        filter: _activeTab.toFilter(),
        currentUserId: _currentUserId,
        limit: _pageSize,
      ),
    ).listen(
      (page) {
        _nextCursor = page.nextCursor;
        _queryCache[_cacheKey] = _CacheEntry(page: page);

        final mergedItems = page.items
            .map((item) => _localOverrides[item.id] ?? item)
            .toList();

        _safeEmit(
          SearchCompetitionSuccess(
            competitions: mergedItems,
            hasReachedMax: !page.hasMore,
          ),
        );
      },
      onError: (error) {
        _safeEmit(SearchCompetitionError(error.toString()));
      },
    );
  }

  Future<void> _executeSearchQuery() async {
    final localToken = ++_searchRequestToken;

    final result = await _searchActiveCompetitionsUseCase(
      SearchActiveCompetitionsParams(
        query: _currentKeyword,
        filter: _activeTab.toFilter(),
        currentUserId: _currentUserId,
        limit: _pageSize,
      ),
    );

    if (localToken != _searchRequestToken || isClosed) return;

    result.when(
      onSuccess: (page) {
        if (localToken != _searchRequestToken) return;
        _nextCursor = page.nextCursor;
        _queryCache[_cacheKey] = _CacheEntry(page: page);

        final mergedItems = page.items
            .map((item) => _localOverrides[item.id] ?? item)
            .toList();

        _safeEmit(
          SearchCompetitionSuccess(
            competitions: mergedItems,
            hasReachedMax: !page.hasMore,
          ),
        );
      },
      onFailure: (failure) {
        if (localToken != _searchRequestToken) return;
        _safeEmit(SearchCompetitionError(failure.message));
      },
    );
  }

  Future<void> loadMore() async {
    final currentState = state;

    if (currentState is! SearchCompetitionSuccess ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore ||
        _nextCursor == null) {
      return;
    }

    _safeEmit(currentState.copyWith(isLoadingMore: true));

    if (_currentKeyword.isNotEmpty) {
      await _loadMoreSearch(currentState);
    } else {
      await _loadMoreStream(currentState);
    }
  }

  Future<void> _loadMoreSearch(SearchCompetitionSuccess currentState) async {
    final loadMoreToken = _searchRequestToken;

    final result = await _searchActiveCompetitionsUseCase(
      SearchActiveCompetitionsParams(
        query: _currentKeyword,
        filter: _activeTab.toFilter(),
        currentUserId: _currentUserId,
        limit: _pageSize,
        startAfter: _nextCursor,
      ),
    );

    if (loadMoreToken != _searchRequestToken || isClosed) return;

    result.when(
      onSuccess: (page) {
        if (loadMoreToken != _searchRequestToken) return;
        _nextCursor = page.nextCursor;
        _appendUniqueItems(currentState, page);
      },
      onFailure: (_) {
        if (loadMoreToken != _searchRequestToken) return;
        _safeEmit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<void> _loadMoreStream(SearchCompetitionSuccess currentState) async {
    _cancelStream();
    _streamSubscription = _streamActiveCompetitionsUseCase(
      StreamActiveCompetitionsParams(
        filter: _activeTab.toFilter(),
        currentUserId: _currentUserId,
        limit: _pageSize,
        startAfter: _nextCursor,
      ),
    ).listen(
      (page) {
        _cancelStream();
        _nextCursor = page.nextCursor;
        _appendUniqueItems(currentState, page);
      },
      onError: (_) {
        _safeEmit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  void _appendUniqueItems(
    SearchCompetitionSuccess currentState,
    CompetitionPage<CompetitionEntity> page,
  ) {
    final existingIds = currentState.competitions.map((c) => c.id).toSet();
    final uniqueNewItems = page.items
        .where((c) => !existingIds.contains(c.id))
        .map((c) => _localOverrides[c.id] ?? c)
        .toList();

    _safeEmit(
      SearchCompetitionSuccess(
        competitions: [...currentState.competitions, ...uniqueNewItems],
        hasReachedMax: !page.hasMore || uniqueNewItems.isEmpty,
        isLoadingMore: false,
      ),
    );
  }

  void updateCompetitionInList(CompetitionEntity updatedCompetition) {
    _localOverrides[updatedCompetition.id] = updatedCompetition;
    _queryCache.clear();

    final currentState = state;
    if (currentState is SearchCompetitionSuccess) {
      final updatedList = currentState.competitions.map((comp) {
        return comp.id == updatedCompetition.id ? updatedCompetition : comp;
      }).toList();

      _safeEmit(currentState.copyWith(competitions: updatedList));
    }
  }

  void removeCompetitionLocally(String competitionId) {
    _localOverrides.remove(competitionId);
    _queryCache.clear();

    final currentState = state;
    if (currentState is SearchCompetitionSuccess) {
      final updatedList = currentState.competitions
          .where((comp) => comp.id != competitionId)
          .toList();

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

          final updated = comp.copyWith(participantsCount: newCount);
          _localOverrides[competitionId] = updated;
          return updated;
        }
        return comp;
      }).toList();

      _safeEmit(currentState.copyWith(competitions: updatedList));
    }
  }

  void _cancelStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _safeEmit(SearchCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelStream();
    _localOverrides.clear();
    _queryCache.clear();
    return super.close();
  }
}
