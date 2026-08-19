import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/domain/usecases/switch_team_use_case.dart';

abstract class TeamState {}
class TeamInitial extends TeamState {}
class TeamLoading extends TeamState {}
class TeamLoaded extends TeamState {
  final List<TeamEntity> teams;
  TeamLoaded(this.teams);
}
class TeamActionSuccess extends TeamState {
  final String message;
  TeamActionSuccess(this.message);
}
class TeamError extends TeamState {
  final String message;
  TeamError(this.message);
}

class TeamCubit extends Cubit<TeamState> {
  final ICompetitionRepository repository;
  final SwitchTeamUseCase switchTeamUseCase;
  StreamSubscription<List<TeamEntity>>? _teamsSubscription;

  TeamCubit({
    required this.repository,
    required this.switchTeamUseCase,
  }) : super(TeamInitial());

  /// Subscribe to real-time team changes
  void watchTeams(String competitionId) {
    emit(TeamLoading());
    _teamsSubscription?.cancel();
    _teamsSubscription = repository.streamTeams(competitionId).listen(
      (teams) {
        emit(TeamLoaded(teams));
      },
      onError: (error) {
        emit(TeamError(error.toString()));
      },
    );
  }

  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) async {
    final result = await repository.joinTeam(
      competitionId: competitionId,
      teamId: teamId,
      joinCode: joinCode,
    );
    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(TeamActionSuccess('Joined team successfully!')),
    );
  }

  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
  }) async {
    final result = await repository.leaveTeam(
      competitionId: competitionId,
      teamId: teamId,
    );
    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(TeamActionSuccess('Left team successfully!')),
    );
  }

  Future<void> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    final result = await switchTeamUseCase(
      competitionId: competitionId,
      fromTeamId: fromTeamId,
      toTeamId: toTeamId,
      joinCode: joinCode,
    );
    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(TeamActionSuccess('Switched team successfully!')),
    );
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}