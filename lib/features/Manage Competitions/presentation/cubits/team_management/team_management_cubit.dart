import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

import '../../../domain/usecases/team/create_team_usecase.dart';
import '../../../domain/usecases/team/delete_team_usecase.dart';
import '../../../domain/usecases/team/remove_member_usecase.dart';
import '../../../domain/usecases/team/stream_teams_manage_usecase.dart';
import '../../../domain/usecases/team/update_member_points_usecase.dart';
import 'team_management_state.dart';

class TeamManagementCubit extends Cubit<TeamManagementState> {
  final StreamTeamsManageUseCase _streamTeamsUseCase;
  final CreateTeamUseCase _createTeamUseCase;
  final DeleteTeamUseCase _deleteTeamUseCase;
  final RemoveMemberUseCase _removeMemberUseCase;
  final UpdateMemberPointsUseCase _updateMemberPointsUseCase;

  StreamSubscription? _teamsSubscription;

  TeamManagementCubit({
    required StreamTeamsManageUseCase streamTeamsUseCase,
    required CreateTeamUseCase createTeamUseCase,
    required DeleteTeamUseCase deleteTeamUseCase,
    required RemoveMemberUseCase removeMemberUseCase,
    required UpdateMemberPointsUseCase updateMemberPointsUseCase,
  })  : _streamTeamsUseCase = streamTeamsUseCase,
        _createTeamUseCase = createTeamUseCase,
        _deleteTeamUseCase = deleteTeamUseCase,
        _removeMemberUseCase = removeMemberUseCase,
        _updateMemberPointsUseCase = updateMemberPointsUseCase,
        super(const TeamManagementInitial());

  void listenToTeams(String competitionId) {
    _safeEmit(TeamManagementLoading(
      teams: state.teams,
      expandedTeamId: state.expandedTeamId,
      showAllTeams: state.showAllTeams,
    ));

    _teamsSubscription?.cancel();
    _teamsSubscription = _streamTeamsUseCase(competitionId).listen(
      (teams) {
        if (state is TeamManagementLoaded) {
          _safeEmit((state as TeamManagementLoaded).copyWith(teams: teams));
        } else {
          _safeEmit(TeamManagementLoaded(
            teams: teams,
            expandedTeamId: state.expandedTeamId,
            showAllTeams: state.showAllTeams,
          ));
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
  required String ownerId, // Pass current user ID from UI/Auth
  String? joinCode,
}) async {
  _safeEmit(TeamManagementLoading(teams: state.teams));

  final team = TeamEntity(
    id: '', // Database handles assignment
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

  void toggleExpandTeam(String teamId) {
    final newExpandedId = state.expandedTeamId == teamId ? null : teamId;
    if (state is TeamManagementLoaded) {
      _safeEmit((state as TeamManagementLoaded).copyWith(expandedTeamId: newExpandedId));
    }
  }

  void toggleShowAllTeams() {
    if (state is TeamManagementLoaded) {
      _safeEmit((state as TeamManagementLoaded).copyWith(showAllTeams: !state.showAllTeams));
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

  Future<void> removeTeamMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  }) async {
    _safeEmit(TeamManagementLoading(teams: state.teams));
    final result = await _removeMemberUseCase(
      competitionId: competitionId,
      teamId: teamId,
      memberId: memberId,
    );

    switch (result) {
      case Success():
        _safeEmit(TeamActionSuccess(
          'Member removed from team',
          teams: state.teams,
        ));
      case Failure(:final message):
        _safeEmit(TeamManagementFailure(
          message,
          teams: state.teams,
        ));
    }
  }

  Future<void> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int deltaPoints,
  }) async {
    final result = await _updateMemberPointsUseCase(
      competitionId: competitionId,
      teamId: teamId,
      memberId: memberId,
      points: deltaPoints,
    );

    switch (result) {
      case Success():
        _safeEmit(TeamActionSuccess(
          'Points updated',
          teams: state.teams,
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