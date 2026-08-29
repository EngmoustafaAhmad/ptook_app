import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

import '../../../domain/usecases/team/create_team_usecase.dart';
import '../../../domain/usecases/team/delete_team_usecase.dart';
import '../../../domain/usecases/team/remove_team_participant_usecase.dart';
import '../../../domain/usecases/team/stream_teams_manage_usecase.dart';
import '../../../domain/usecases/team/update_team_participant_points_usecase.dart';
import 'team_management_state.dart';

class TeamManagementCubit extends Cubit<TeamManagementState> {
  final StreamTeamsManageUseCase _streamTeamsUseCase;
  final CreateTeamUseCase _createTeamUseCase;
  final DeleteTeamUseCase _deleteTeamUseCase;
  final UpdateTeamParticipantPointsUseCase _updateTeamParticipantPointsUseCase;
  final RemoveTeamParticipantUseCase _removeTeamParticipantUseCase;

  StreamSubscription? _teamsSubscription;

  TeamManagementCubit({
    required StreamTeamsManageUseCase streamTeamsUseCase,
    required CreateTeamUseCase createTeamUseCase,
    required DeleteTeamUseCase deleteTeamUseCase,
    required UpdateTeamParticipantPointsUseCase updateTeamParticipantPointsUseCase,
    required RemoveTeamParticipantUseCase removeTeamParticipantUseCase,
  })  : _streamTeamsUseCase = streamTeamsUseCase,
        _createTeamUseCase = createTeamUseCase,
        _deleteTeamUseCase = deleteTeamUseCase,
        _updateTeamParticipantPointsUseCase = updateTeamParticipantPointsUseCase,
        _removeTeamParticipantUseCase = removeTeamParticipantUseCase,
        super(const TeamManagementInitial());

  void listenToTeams(String competitionId) {
    _safeEmit(TeamManagementLoading(teams: state.teams));

    _teamsSubscription?.cancel();
    _teamsSubscription = _streamTeamsUseCase(competitionId).listen(
      (teams) {
        if (state is TeamManagementLoaded) {
          _safeEmit((state as TeamManagementLoaded).copyWith(teams: teams));
        } else {
          _safeEmit(TeamManagementLoaded(teams: teams));
        }
      },
      onError: (error) => _safeEmit(
        TeamManagementFailure(error.toString(), teams: state.teams),
      ),
    );
  }

  Future<void> createTeam({
    required String competitionId,
    required String teamName,
    required bool isPrivate,
    required String ownerId,
    String? joinCode,
  }) async {
    _safeEmit(TeamManagementLoading(teams: state.teams));

    final team = TeamEntity(
      id: '',
      competitionId: competitionId,
      name: teamName,
      isPrivate: isPrivate,
      joinCode: joinCode,
      ownerId: ownerId,
      createdAt: DateTime.now(),
    );

    final result = await _createTeamUseCase(team);

    switch (result) {
      case Success():
        _safeEmit(TeamActionSuccess(
          'Team created successfully',
          teams: state.teams,
        ));
      case Failure(:final message):
        _safeEmit(TeamManagementFailure(
          message,
          teams: state.teams,
        ));
    }
  }

  Future<void> deleteTeam({
    required String competitionId,
    required String teamId,
  }) async {
    _safeEmit(TeamManagementLoading(teams: state.teams));
    final result = await _deleteTeamUseCase(
      competitionId: competitionId,
      teamId: teamId,
    );

    switch (result) {
      case Success():
        _safeEmit(TeamActionSuccess(
          'Team deleted successfully',
          teams: state.teams,
        ));
      case Failure(:final message):
        _safeEmit(TeamManagementFailure(
          message,
          teams: state.teams,
        ));
    }
  }

  Future<void> updateTeamParticipantPoints({
  required String competitionId,
  required String teamId,
  required String participantId,
  required int addedPoints,
}) async {
  // 1. Optimistically update local teams state
  final updatedTeams = state.teams.map((team) {
    if (team.id == teamId) {
      final updatedMembers = team.members.map((member) {
        if (member.id == participantId) {
          return member.copyWith(points: member.points + addedPoints);
        }
        return member;
      }).toList();

      final newTotalPoints = updatedMembers.fold<int>(
        0,
        (sum, member) => sum + member.points,
      );

      return team.copyWith(
        members: updatedMembers,
        totalPoints: newTotalPoints,
      );
    }
    return team;
  }).toList();

  _safeEmit(TeamActionSuccess(
    'Participant points updated successfully',
    teams: updatedTeams,
  ));

  // 2. Call backend use case
  final result = await _updateTeamParticipantPointsUseCase(
    competitionId: competitionId,
    teamId: teamId,
    participantId: participantId,
    addedPoints: addedPoints,
  );

  if (result is Failure) {
    // Roll back state or emit failure if request fails
    _safeEmit(TeamManagementFailure(
      result.message,
      teams: state.teams,
    ));
  }
}

Future<void> removeTeamParticipant({
    required String competitionId,
    required String teamId,
    required String participantId,
  }) async {
    _safeEmit(TeamManagementLoading(teams: state.teams));

    final result = await _removeTeamParticipantUseCase(
      competitionId: competitionId,
      teamId: teamId,
      participantId: participantId,
    );

    switch (result) {
      case Success():
        // Optimistically remove member from local Cubit state
        final updatedTeams = state.teams.map((team) {
          if (team.id == teamId) {
            final updatedMembers = team.members
                .where((m) => m.id != participantId)
                .toList();

            final newTotal = updatedMembers.fold<int>(
              0,
              (sum, member) => sum + member.points,
            );

            return team.copyWith(
              members: updatedMembers,
              totalPoints: newTotal,
            );
          }
          return team;
        }).toList();

        _safeEmit(TeamActionSuccess(
          'Member removed successfully',
          teams: updatedTeams,
        ));
      case Failure(:final message):
        _safeEmit(TeamManagementFailure(
          message,
          teams: state.teams,
        ));
    }
  }

  void _safeEmit(TeamManagementState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}