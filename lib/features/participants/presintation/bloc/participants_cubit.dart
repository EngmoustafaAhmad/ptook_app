import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/participants/domain/usecases/assign_podium_stars_usecase.dart';
import 'package:ptook/features/participants/domain/usecases/update_participant_points_usecase.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart';

import '../../domain/usecases/get_competition_participants_usecase.dart';
import '../../domain/usecases/join_competition_usecase.dart';
import '../../domain/usecases/leave_competition_usecase.dart';

class ParticipantCubit extends Cubit<ParticipantState> {
  final JoinCompetitionUseCase joinCompetitionUseCase;
  final LeaveCompetitionUseCase leaveCompetitionUseCase;
  final GetCompetitionParticipantsUseCase getCompetitionParticipantsUseCase;
  final UpdatePointsUseCase updatePointsUseCase;
  final AssignPodiumStarsUseCase assignPodiumStarsUseCase;

  ParticipantCubit({
    required this.joinCompetitionUseCase,
    required this.leaveCompetitionUseCase,
    required this.getCompetitionParticipantsUseCase,
    required this.updatePointsUseCase,
    required this.assignPodiumStarsUseCase,
  }) : super(ParticipantInitial());

  /// Fetches participants for the leaderboard
  Future<void> fetchParticipants(String competitionId) async {
    _safeEmit(ParticipantLoading());

    try {
      final participants =
          await getCompetitionParticipantsUseCase(competitionId);
      _safeEmit(ParticipantLoaded(participants: participants));
    } catch (e) {
      _safeEmit(
        ParticipantFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Executes the join competition workflow and refreshes list
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  }) async {
    _safeEmit(ParticipantActionLoading());

    try {
      await joinCompetitionUseCase(
        competitionId: competitionId,
        userId: userId,
        role: role,
        teamId: teamId,
      );

      _safeEmit(
        const JoinCompetitionSuccess(
          message: 'Successfully joined the competition!',
        ),
      );

      // Re-fetch list after joining
      await fetchParticipants(competitionId);
    } catch (e) {
      _safeEmit(
        ParticipantFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Executes the leave competition workflow and refreshes list
  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(ParticipantActionLoading());

    try {
      await leaveCompetitionUseCase(
        competitionId: competitionId,
        userId: userId,
      );

      _safeEmit(
        const LeaveCompetitionSuccess(
          message: 'Successfully left the competition.',
        ),
      );

      // Re-fetch list after leaving
      await fetchParticipants(competitionId);
    } catch (e) {
      _safeEmit(
        ParticipantFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Updates points for a participant
  Future<void> updatePoints({
    required String competitionId,
    required String userId,
    required int points,
  }) async {
    try {
      await updatePointsUseCase(
        competitionId: competitionId,
        userId: userId,
        points: points,
      );

      // Refresh leaderboard after points change
      await fetchParticipants(competitionId);
    } catch (e) {
      _safeEmit(
        ParticipantFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Assigns podium stars upon competition conclusion
  Future<void> assignPodiumStars({
    required String competitionId,
    required String userId,
    required int rank,
  }) async {
    try {
      await assignPodiumStarsUseCase(
        competitionId: competitionId,
        userId: userId,
        rank: rank,
      );

      await fetchParticipants(competitionId);
    } catch (e) {
      _safeEmit(
        ParticipantFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Safety check to prevent emitting states if the Cubit was closed during async calls
  void _safeEmit(ParticipantState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  /// Sanitizes raw exception strings for UI display
  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message.isEmpty ? 'An unexpected error occurred.' : message;
  }
}