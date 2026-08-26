import 'package:ptook/core/utils/result.dart';
import '../../../../shared/domain/entities/competition_entity.dart';
import '../../repositories/i_manage_competition_repository.dart';

class UpdateCompetitionUseCase {
  final IManageCompetitionRepository repository;

  UpdateCompetitionUseCase(this.repository);

  Future<Result<void>> call(CompetitionEntity competition) async {
    return await repository.updateCompetition(competition);
  }
}