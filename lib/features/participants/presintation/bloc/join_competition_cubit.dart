import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/join_competition_usecase.dart';
import '../../domain/usecases/leave_competition_usecase.dart';
import 'join_competition_state.dart';

class JoinCompetitionCubit extends Cubit<JoinCompetitionState> {
  final JoinCompetitionUseCase joinCompetitionUseCase;
  final LeaveCompetitionUseCase leaveCompetitionUseCase;

  JoinCompetitionCubit({
    required this.joinCompetitionUseCase,
    required this.leaveCompetitionUseCase, required FirebaseAuth auth,
  }) : super(JoinCompetitionInitial());

  /// Triggers joining a competition
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

  /// Triggers leaving a competition
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

  /// Prevents emitting after the Cubit has been disposed
  void _safeEmit(JoinCompetitionState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  /// Cleans raw error strings for UI display
  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message.isEmpty ? 'An unexpected error occurred.' : message;
  }
}