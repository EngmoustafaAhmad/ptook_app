// lib/features/competitions/data/datasources/team_remote_data_source_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import 'team_remote_data_source.dart';

class TeamRemoteDataSourceImpl implements ITeamRemoteDataSource {
  final FirebaseFirestore firestore;

  TeamRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<void> createTeam(TeamModel team) async {
    await firestore
        .collection('competitions')
        .doc(team.competitionId)
        .collection('teams')
        .doc(team.id)
        .set(team.toJson());
  }

  @override
  Future<List<TeamModel>> getTeams(String competitionId) async {
    final snapshot = await firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('teams')
        .get();

    // 🎯 تمرير البرامترين المطلوبين لـ fromJson: (doc.data(), doc.id)
    return snapshot.docs.map((doc) {
      return TeamModel.fromJson(doc.data(), doc.id);
    }).toList();
  }
}