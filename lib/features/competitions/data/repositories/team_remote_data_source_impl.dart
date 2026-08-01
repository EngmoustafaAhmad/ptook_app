import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/competitions/data/datasources/team_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/team_model.dart';

class TeamRemoteDataSourceImpl
implements ITeamRemoteDataSource {



final FirebaseFirestore firestore;



TeamRemoteDataSourceImpl({
required this.firestore
});





@override
Future<void> createTeam(
TeamModel team
) async {



await firestore

.collection('competitions')

.doc(team.competitionId)

.collection('teams')

.doc(team.id)

.set(
team.toJson()
);



}





@override
Future<List<TeamModel>> getTeams(
String competitionId
) async {


final snapshot =
await firestore

.collection('competitions')

.doc(competitionId)

.collection('teams')

.get();



return snapshot.docs.map((doc){


return TeamModel.fromJson({

'id':doc.id,

...doc.data()


});


}).toList();



}
}