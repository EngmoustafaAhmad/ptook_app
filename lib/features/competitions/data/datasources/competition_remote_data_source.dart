import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/core/errors/exceptions.dart'; // Adjust path to your custom exceptions
import 'package:ptook/features/competitions/data/models/competition_model.dart';

abstract class ICompetitionRemoteDataSource {
  Future<void> createCompetition(CompetitionModel competition);
  Future<List<CompetitionModel>> searchPublicCompetitions(String keyword);
  Future<CompetitionModel?> getCompetitionByCode(String code);
  Future<List<CompetitionModel>> getPublicCompetitions({int limit = 20});
}

class CompetitionRemoteDataSourceImpl implements ICompetitionRemoteDataSource {
  final FirebaseFirestore firestore;

  CompetitionRemoteDataSourceImpl({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<void> createCompetition(CompetitionModel model) async {
    try {
      await _competitionsRef.doc(model.id).set(model.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create competition');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> searchPublicCompetitions(String keyword) async {
    final cleanKeyword = keyword.trim().toLowerCase();
    if (cleanKeyword.isEmpty) {
      return getPublicCompetitions();
    }

    try {
      final snapshot = await _competitionsRef
          .where('isPublic', isEqualTo: true)
          .where('searchKeywords', arrayContains: cleanKeyword)
          .limit(20)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Search query failed');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CompetitionModel?> getCompetitionByCode(String code) async {
    try {
      final snapshot = await _competitionsRef
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return _mapDocToModel(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get competition by code');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> getPublicCompetitions({int limit = 20}) async {
    try {
      final snapshot = await _competitionsRef
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch public competitions');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // 💡 Private Helper to reduce code duplication
  CompetitionModel _mapDocToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw const ServerException(message: 'Competition document contains no data');
    }
    return CompetitionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}