import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../repositories/i_search_competition_repository.dart';

class GetCompetitionByCodeUseCase {
  final ISearchCompetitionRepository _repository;

  GetCompetitionByCodeUseCase(this._repository);

  Future<Result<CompetitionEntity?>> call(String code) {
    return _repository.getCompetitionByCode(code);
  }
}