import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_model.dart';



abstract class ITeamRemoteDataSource {


Future<void> createTeam(
TeamModel team
);


Future<List<TeamModel>>
getTeams(
String competitionId
);
}