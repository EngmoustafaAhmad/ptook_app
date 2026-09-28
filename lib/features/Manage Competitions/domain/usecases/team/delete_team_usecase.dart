import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/team/i_manage_team_repository.dart';

class DeleteTeamUseCase {
  final IManageTeamRepository repository;

  DeleteTeamUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
  }) async {
    return await repository.deleteTeam(
      competitionId: competitionId,
      teamId: teamId,
    );
  }
}