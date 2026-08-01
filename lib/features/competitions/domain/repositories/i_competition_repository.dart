import '../entities/competition_entity.dart';


abstract class ICompetitionRepository {


  Future<void> createCompetition(
      CompetitionEntity competition,
  );



  Future<List<CompetitionEntity>>
  searchPublicCompetitions(
      String keyword,
  );


}