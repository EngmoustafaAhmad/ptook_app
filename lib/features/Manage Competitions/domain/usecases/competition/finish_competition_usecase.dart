import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';

class FinishCompetitionUseCase {
  final IManageCompetitionRepository repository;

  FinishCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) async {
    return await repository.finishCompetition(competitionId);
  }
}