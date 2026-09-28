import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';
import '../../../../core/utils/result.dart';

class JoinTeamUseCase {
  final IViewTeamRepository repository;

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
  final IViewTeamRepository repository;

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

