import '../entities/team_entity.dart';



abstract class ITeamRepository {



  Future<List<TeamEntity>> getTeams(

      String competitionId

      );



  Future<void> createTeam(

      TeamEntity team

      );



}