import '../entities/team_entity.dart';


abstract class ITeamRepository {


  Future<void> createTeam(
      TeamEntity team
  );



  Future<List<TeamEntity>> getTeams(
      String competitionId
  );


}