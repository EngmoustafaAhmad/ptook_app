import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

abstract class IManageCompetitionRepository {
  Future<Result<void>> updateCompetition(
    CompetitionEntity competition,
  );

  Future<Result<void>> deleteCompetition(String competitionId);

  Future<Result<void>> finishCompetition(String competitionId);
  
  // Realtime Streams
  Stream<CompetitionEntity> streamCompetition(String competitionId);
}