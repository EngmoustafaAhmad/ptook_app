import '../entities/competition_entity.dart';

abstract class ICompetitionRepository {

  Future<void> createCompetition(
      CompetitionEntity competition
  );

}