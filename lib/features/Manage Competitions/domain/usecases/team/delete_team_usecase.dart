import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class DeleteTeamUseCase {
  final IManageCompetitionRepository repository;

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