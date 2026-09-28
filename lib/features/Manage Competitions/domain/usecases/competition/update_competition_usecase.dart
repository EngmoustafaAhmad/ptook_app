import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/competition/i_manage_competition_repository.dart';
import '../../../../shared/domain/entities/competition_entity.dart';

class UpdateCompetitionUseCase {
  final IManageCompetitionRepository repository;

  UpdateCompetitionUseCase(this.repository);

  Future<Result<void>> call(CompetitionEntity competition) async {
    return await repository.updateCompetition(competition);
  }
}