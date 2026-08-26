import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../repositories/i_create_competition_repository.dart';

class CreateCompetitionUseCase {
  final ICreateCompetitionRepository _repository;

  CreateCompetitionUseCase(this._repository);

  Future<Result<void>> call(CompetitionEntity competition) {
    return _repository.createCompetition(competition);
  }
}