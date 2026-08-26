import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/create_competition/data/datasources/i_create_competition_remote_datasource.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';

class CreateCompetitionRemoteDataSourceImpl
    implements ICreateCompetitionRemoteDataSource {
  final FirebaseFirestore _firestore;

  CreateCompetitionRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<void> createCompetition(CompetitionModel competition) async {
    await _firestore
        .collection('competitions')
        .doc(competition.id)
        .set(competition.toJson());
  }
}