import '../entities/team_entity.dart';
import '../repositories/i_team_repository.dart';



class CreateTeamUseCase {


  final ITeamRepository repository;



  CreateTeamUseCase({

    required this.repository,

  });




  Future<void> call(
      TeamEntity team
  ) async {


    await repository.createTeam(
      team,
    );


  }


}