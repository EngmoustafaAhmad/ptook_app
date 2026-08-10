  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
  import 'package:ptook/features/competitions/domain/repositories/competition_repository.dart';
  import 'competition_state.dart';

  class CompetitionCubit extends Cubit<CompetitionState> {
    final CompetitionRepository _repository;

    CompetitionCubit(this._repository) : super(CompetitionInitial());

    /// Fetch all active public competitions
    Future<void> fetchCompetitions() async {
      emit(CompetitionLoading());
      final result = await _repository.getCompetitions();

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (competitions) => emit(CompetitionsLoaded(competitions)),
      );
    }

    /// Search competitions by keyword
    Future<void> searchCompetitions(String keyword) async {
      if (keyword.trim().isEmpty) {
        await fetchCompetitions();
        return;
      }

      emit(CompetitionLoading());
      final result = await _repository.searchPublicCompetitions(keyword);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (competitions) => emit(CompetitionsLoaded(competitions)),
      );
    }

    /// Fetch single competition details by ID
    Future<void> fetchCompetitionById(String competitionId) async {
      emit(CompetitionLoading());
      final result = await _repository.getCompetitionById(competitionId);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (competition) => emit(CompetitionDetailsLoaded(competition)),
      );
    }

    /// Fetch single competition by invite code
    Future<void> fetchCompetitionByCode(String code) async {
      if (code.trim().isEmpty) {
        emit(const CompetitionError("Invite code cannot be empty."));
        return;
      }

      emit(CompetitionLoading());
      final result = await _repository.getCompetitionByCode(code.trim().toUpperCase());

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (competition) {
          if (competition == null) {
            emit(const CompetitionError("No competition found with this code."));
          } else {
            emit(CompetitionDetailsLoaded(competition));
          }
        },
      );
    }

    /// Join a competition
    Future<void> joinCompetition(String competitionId) async {
      emit(CompetitionLoading());
      final result = await _repository.joinCompetition(competitionId);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (_) async {
          emit(const CompetitionActionSuccess("Successfully joined competition!"));
          await fetchCompetitions();
        },
      );
    }

    /// Leave a competition
    Future<void> leaveCompetition(String competitionId) async {
      emit(CompetitionLoading());
      final result = await _repository.leaveCompetition(competitionId);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (_) async {
          emit(const CompetitionActionSuccess("Successfully left competition."));
          await fetchCompetitions();
        },
      );
    }

    /// Create a new competition
    Future<void> createCompetition(CompetitionEntity competition) async {
      emit(CompetitionLoading());
      final result = await _repository.createCompetition(competition);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (_) async {
          emit(const CompetitionActionSuccess("Competition created successfully!"));
          await fetchCompetitions();
        },
      );
    }

    /// Update an existing competition
    Future<void> updateCompetition(CompetitionEntity competition) async {
      emit(CompetitionLoading());
      final result = await _repository.updateCompetition(competition);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (_) async {
          emit(const CompetitionActionSuccess("Competition updated successfully!"));
          await fetchCompetitionById(competition.id);
        },
      );
    }

    /// Delete a competition
    Future<void> deleteCompetition(String competitionId) async {
      emit(CompetitionLoading());
      final result = await _repository.deleteCompetition(competitionId);

      result.fold(
        (failure) => emit(CompetitionError(failure.message)),
        (_) async {
          emit(const CompetitionActionSuccess("Competition deleted successfully."));
          await fetchCompetitions();
        },
      );
    }
  }