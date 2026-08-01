import '../../domain/entities/team_entity.dart';

import '../../domain/repositories/i_team_repository.dart';

import '../datasources/team_remote_data_source.dart';

import '../models/team_model.dart';



class TeamRepositoryImpl 
    implements ITeamRepository {



final ITeamRemoteDataSource remoteDataSource;



TeamRepositoryImpl({

required this.remoteDataSource,

});





@override
Future<void> createTeam(
TeamEntity team
) async {



final model = TeamModel(

id: team.id,

name: team.name,

competitionId:
team.competitionId,

ownerId:
team.ownerId,

joinCode:
team.joinCode,

members:
team.members,

createdAt:
team.createdAt,


);



await remoteDataSource.createTeam(
model
);



}







@override
Future<List<TeamEntity>> getTeams(
String competitionId
) async {



return await remoteDataSource.getTeams(
competitionId
);



}
}