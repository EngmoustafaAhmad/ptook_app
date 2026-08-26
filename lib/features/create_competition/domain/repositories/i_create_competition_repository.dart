import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

abstract class ICreateCompetitionRepository {
  Future<Result<void>> createCompetition(CompetitionEntity competition);
}