import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'competition_state.dart';

class CompetitionCubit extends Cubit<CompetitionState> {
  final ICompetitionRepository _repository;

  static const int _pageSize = 10;
  bool _isFetchingMore = false;
  String _currentKeyword = '';

  CompetitionCubit(this._repository) : super(CompetitionInitial());

  /// Fetch initial active public competitions (Resets any active search query)
  Future<void> fetchCompetitions() async {
    _currentKeyword = '';
    _safeEmit(CompetitionLoading());

    final result = await _repository.getPublicCompetitions(
      limit: _pageSize,
    );

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (competitions) => _safeEmit(
        CompetitionsLoaded(
          competitions: competitions,
          hasReachedMax: competitions.length < _pageSize,
        ),
      ),
    );
  }

  /// Search public competitions by query keyword with pagination reset
  Future<void> searchCompetitions([String query = '']) async {
    final sanitizedQuery = query.trim().toLowerCase();
    _currentKeyword = sanitizedQuery;

    if (sanitizedQuery.isEmpty) {
      await fetchCompetitions();
      return;
    }

    _safeEmit(CompetitionLoading());

    final result = await _repository.searchPublicCompetitions(
      query: _currentKeyword,
      limit: _pageSize,
    );

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (competitions) => _safeEmit(
        CompetitionsLoaded(
          competitions: competitions,
          hasReachedMax: competitions.length < _pageSize,
        ),
      ),
    );
  }

  /// Load next page on scroll using the active `_currentKeyword` query if present
  Future<void> loadMoreCompetitions() async {
    final currentState = state;

    if (currentState is! CompetitionsLoaded ||
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

    final result = _currentKeyword.isEmpty
        ? await _repository.getPublicCompetitions(
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          )
        : await _repository.searchPublicCompetitions(
            query: _currentKeyword,
            limit: _pageSize,
            lastCompetitionId: lastCompetitionId,
          );

    _isFetchingMore = false;

    result.fold(
      (failure) => _safeEmit(currentState.copyWith(isLoadingMore: false)),
      (newCompetitions) {
        if (newCompetitions.isEmpty) {
          _safeEmit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          _safeEmit(
            CompetitionsLoaded(
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

  /// Fetch single competition details by ID
  Future<void> fetchCompetitionById(String competitionId) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.getCompetitionById(competitionId);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (competition) => _safeEmit(CompetitionDetailsLoaded(competition)),
    );
  }

  /// Fetch single competition by invite code
  Future<void> fetchCompetitionByCode(String code) async {
    final sanitizedCode = code.trim().toUpperCase();
    if (sanitizedCode.isEmpty) {
      _safeEmit(const CompetitionError("Invite code cannot be empty."));
      return;
    }

    _safeEmit(CompetitionLoading());
    final result = await _repository.getCompetitionByCode(sanitizedCode);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (competition) {
        if (competition == null) {
          _safeEmit(const CompetitionError("No competition found with this code."));
        } else {
          _safeEmit(CompetitionDetailsLoaded(competition));
        }
      },
    );
  }

  /// Join a competition
  Future<void> joinCompetition(String competitionId) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.joinCompetition(competitionId);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (_) async {
        _safeEmit(const CompetitionActionSuccess("Successfully joined competition!"));
        await fetchCompetitions();
      },
    );
  }

  /// Leave a competition
  Future<void> leaveCompetition(String competitionId) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.leaveCompetition(competitionId);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (_) async {
        _safeEmit(const CompetitionActionSuccess("Successfully left competition."));
        await fetchCompetitions();
      },
    );
  }

  /// Create a new competition
  Future<void> createCompetition(CompetitionEntity competition) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.createCompetition(competition);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (_) async {
        _safeEmit(const CompetitionActionSuccess("Competition created successfully!"));
        await fetchCompetitions();
      },
    );
  }

  /// Update an existing competition
  Future<void> updateCompetition(CompetitionEntity competition) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.updateCompetition(competition);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (_) async {
        _safeEmit(const CompetitionActionSuccess("Competition updated successfully!"));
        await fetchCompetitionById(competition.id);
      },
    );
  }

  /// Delete a competition
  Future<void> deleteCompetition(String competitionId) async {
    _safeEmit(CompetitionLoading());
    final result = await _repository.deleteCompetition(competitionId);

    result.fold(
      (failure) => _safeEmit(CompetitionError(failure.message)),
      (_) async {
        _safeEmit(const CompetitionActionSuccess("Competition deleted successfully."));
        await fetchCompetitions();
      },
    );
  }

  /// Prevents `StateError` if an async operation completes after Cubit is disposed
  void _safeEmit(CompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }
}