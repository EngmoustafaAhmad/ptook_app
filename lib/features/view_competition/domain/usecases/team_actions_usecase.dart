import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class JoinTeamUseCase {
  final IViewCompetitionRepository repository;

  JoinTeamUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) {
    return repository.joinTeam(
      competitionId: competitionId,
      teamId: teamId,
      joinCode: joinCode,
    );
  }
}

class LeaveTeamUseCase {
  final IViewCompetitionRepository repository;

  LeaveTeamUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
  }) {
    return repository.leaveTeam(
      competitionId: competitionId,
      teamId: teamId,
    );
  }
}

class SwitchTeamUseCase {
  final IViewCompetitionRepository repository;

  SwitchTeamUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) {
    return repository.switchTeam(
      competitionId: competitionId,
      fromTeamId: fromTeamId,
      toTeamId: toTeamId,
      joinCode: joinCode,
    );
  }
}