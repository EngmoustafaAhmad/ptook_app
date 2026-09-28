import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/competition/i_manage_competition_repository.dart';

class DeleteCompetitionUseCase {
  final IManageCompetitionRepository repository;

  DeleteCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) async {
    return await repository.deleteCompetition(competitionId);
  }
}