import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/domain/usecases/join_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/leave_competition_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/stream_participants_view_usecase.dart';
import 'package:ptook/features/view_competition/domain/usecases/team_actions_usecase.dart';
import 'view_participants_state.dart';

class ViewParticipantsCubit extends Cubit<ViewParticipantsState> {
  final StreamParticipantsViewUseCase _streamParticipantsViewUseCase;
  final JoinCompetitionUseCase _joinCompetitionUseCase;
  final LeaveCompetitionUseCase _leaveCompetitionUseCase;
  final JoinTeamUseCase _joinTeamUseCase;
  final LeaveTeamUseCase _leaveTeamUseCase;
  final SwitchTeamUseCase _switchTeamUseCase;

  StreamSubscription<List<ParticipantEntity>>? _participantsSubscription;
  List<ParticipantEntity> _cachedParticipants = [];

  ViewParticipantsCubit({
    required StreamParticipantsViewUseCase streamParticipantsViewUseCase,
    required JoinCompetitionUseCase joinCompetitionUseCase,
    required LeaveCompetitionUseCase leaveCompetitionUseCase,
    required JoinTeamUseCase joinTeamUseCase,
    required LeaveTeamUseCase leaveTeamUseCase,
    required SwitchTeamUseCase switchTeamUseCase,
  })  : _streamParticipantsViewUseCase = streamParticipantsViewUseCase,
        _joinCompetitionUseCase = joinCompetitionUseCase,
        _leaveCompetitionUseCase = leaveCompetitionUseCase,
        _joinTeamUseCase = joinTeamUseCase,
        _leaveTeamUseCase = leaveTeamUseCase,
        _switchTeamUseCase = switchTeamUseCase,
        super(ViewParticipantsInitial());

  /// Listens to real-time participant stream for a specific competition
  void listenToParticipants(String competitionId) {
    emit(ViewParticipantsLoading());

    _participantsSubscription?.cancel();
    _participantsSubscription = _streamParticipantsViewUseCase(competitionId).listen(
      (participants) {
        _cachedParticipants = participants;
        emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
      },
      onError: (error) {
        emit(ViewParticipantsError(error.toString()));
      },
    );
  }

  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
  }) async {
    emit(ViewParticipantsActionLoading());

    final result = await _joinCompetitionUseCase(competitionId);

    switch (result) {
      case Success():
        emit(const JoinCompetitionSuccess('Successfully joined competition!'));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
      case Failure(:final message):
        emit(ViewParticipantsError(message));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
    }
  }

  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  }) async {
    emit(ViewParticipantsActionLoading());

    final result = await _leaveCompetitionUseCase(competitionId);

    switch (result) {
      case Success():
        _cachedParticipants.removeWhere((p) => p.userId == userId);
        emit(const LeaveCompetitionSuccess('Left the competition successfully.'));
        emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
      case Failure(:final message):
        emit(ViewParticipantsError(message));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
    }
  }

  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) async {
    emit(ViewParticipantsActionLoading());

    final result = await _joinTeamUseCase(
      competitionId: competitionId,
      teamId: teamId,
      joinCode: joinCode,
    );

    switch (result) {
      case Success():
        emit(const JoinCompetitionSuccess('Successfully joined team!'));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
      case Failure(:final message):
        emit(ViewParticipantsError(message));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
    }
  }

  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
  }) async {
    emit(ViewParticipantsActionLoading());

    final result = await _leaveTeamUseCase(
      competitionId: competitionId,
      teamId: teamId,
    );

    switch (result) {
      case Success():
        emit(const LeaveCompetitionSuccess('Left team successfully.'));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
      case Failure(:final message):
        emit(ViewParticipantsError(message));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
    }
  }

  Future<void> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    emit(ViewParticipantsActionLoading());

    final result = await _switchTeamUseCase(
      competitionId: competitionId,
      fromTeamId: fromTeamId,
      toTeamId: toTeamId,
      joinCode: joinCode,
    );

    switch (result) {
      case Success():
        emit(const JoinCompetitionSuccess('Successfully switched teams!'));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
      case Failure(:final message):
        emit(ViewParticipantsError(message));
        if (_cachedParticipants.isNotEmpty) {
          emit(ViewParticipantsLoaded(List.unmodifiable(_cachedParticipants)));
        }
    }
  }

  @override
  Future<void> close() {
    _participantsSubscription?.cancel();
    return super.close();
  }
}