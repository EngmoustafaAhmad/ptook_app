// lib/features/competitions/data/datasources/competition_remote_data_source.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';

abstract class ICompetitionRemoteDataSource {
  Future<void> createCompetition(CompetitionModel model);
}

class CompetitionRemoteDataSourceImpl implements ICompetitionRemoteDataSource {
  final FirebaseDatabase database;

  CompetitionRemoteDataSourceImpl({required this.database});

  @override
  Future<void> createCompetition(CompetitionModel model) async {
    // الرفع المباشر إلى مسار المسابقات في الـ Realtime Database
    await database.ref('competitions/${model.id}').set(model.toJson());
  }
}