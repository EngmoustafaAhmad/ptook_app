import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';

import '../../domain/usecases/join_competition_usecase.dart';
import '../../domain/usecases/leave_competition_usecase.dart';

class ParticipantCubit extends Cubit<JoinCompetitionState> {
  final JoinCompetitionUseCase joinCompetitionUseCase;
  final LeaveCompetitionUseCase leaveCompetitionUseCase;

  ParticipantCubit({
    required this.joinCompetitionUseCase,
    required this.leaveCompetitionUseCase,
  }) : super(JoinCompetitionInitial());

  /// Executes the join competition workflow
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  }) async {
    _safeEmit(JoinCompetitionLoading());

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
    } catch (e) {
      _safeEmit(
        JoinCompetitionFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Executes the leave competition workflow
  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  }) async {
    _safeEmit(JoinCompetitionLoading());

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
    } catch (e) {
      _safeEmit(
        JoinCompetitionFailure(
          errorMessage: _formatErrorMessage(e),
        ),
      );
    }
  }

  /// Safety check to prevent emitting states if the Cubit was closed during async calls
  void _safeEmit(JoinCompetitionState newState) {
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