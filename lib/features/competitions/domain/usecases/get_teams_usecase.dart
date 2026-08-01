import '../entities/team_entity.dart';
import '../repositories/i_team_repository.dart';



class GetTeamsUseCase {


  final ITeamRepository repository;



  GetTeamsUseCase({

    required this.repository,

  });




  Future<List<TeamEntity>> call(

      String competitionId

  ) async {


    return await repository.getTeams(
      competitionId,
    );


  }


}