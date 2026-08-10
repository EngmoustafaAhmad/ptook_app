import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';

abstract class ICompetitionRemoteDataSource {
  Future<List<CompetitionModel>> getCompetitions();
  Future<CompetitionModel> getCompetitionById(String competitionId);
  Future<void> createCompetition(CompetitionModel competition);
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> joinCompetition(String competitionId);
  Future<void> leaveCompetition(String competitionId);
  Future<List<CompetitionModel>> searchPublicCompetitions(String keyword);
  Future<CompetitionModel?> getCompetitionByCode(String code);
  Future<List<CompetitionModel>> getPublicCompetitions({int limit = 20});

  // Realtime Streams
  Stream<CompetitionModel> streamCompetition(String competitionId);
  Stream<List<ParticipantModel>> streamParticipants(String competitionId);
}

class CompetitionRemoteDataSourceImpl implements ICompetitionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CompetitionRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<List<CompetitionModel>> getCompetitions() async {
    return getPublicCompetitions();
  }

  @override
  Future<CompetitionModel> getCompetitionById(String competitionId) async {
    try {
      final doc = await _competitionsRef.doc(competitionId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Competition not found');
      }
      return _mapDocToModel(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get competition');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

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
  Future<void> updateCompetition(CompetitionModel model) async {
    try {
      await _competitionsRef.doc(model.id).update(model.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update competition');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteCompetition(String competitionId) async {
    try {
      await _competitionsRef.doc(competitionId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete competition');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
@override
Future<void> joinCompetition(String competitionId) async {
  final user = auth.currentUser;
  if (user == null) {
    throw const ServerException(message: 'User must be logged in to join');
  }

  try {
    final batch = firestore.batch();
    final compDocRef = _competitionsRef.doc(competitionId);
    final participantDocRef = compDocRef.collection('participants').doc(user.uid);

    // 1. Add user ID atomically to participantIds array on the main competition document
    batch.update(compDocRef, {
      'participantIds': FieldValue.arrayUnion([user.uid]),
    });

    // 2. Build full participant model with actual IDs and default role
    final participantModel = ParticipantModel(
      id: user.uid,
      userId: user.uid,                     //  Use actual user UID
      competitionId: competitionId,         //  Use parameter competitionId
      name: user.displayName ?? 'Anonymous User',
      avatarUrl: user.photoURL ?? '',
      points: 0,
      role: 'participant',                  //  Set default role ('participant' or 'member')
      joinedAt: DateTime.now(),
    );

    batch.set(participantDocRef, participantModel.toJson());

    await batch.commit();
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Failed to join competition');
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}
  @override
  Future<void> leaveCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User must be logged in to leave');
    }

    try {
      final batch = firestore.batch();
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef = compDocRef.collection('participants').doc(user.uid);

      // 1. Remove user ID atomically from participantIds array
      batch.update(compDocRef, {
        'participantIds': FieldValue.arrayRemove([user.uid]),
      });

      // 2. Remove user from participants sub-collection
      batch.delete(participantDocRef);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to leave competition');
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

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================

  @override
  Stream<CompetitionModel> streamCompetition(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .snapshots()
        .map((doc) => _mapDocToModel(doc));
  }

  @override
  Stream<List<ParticipantModel>> streamParticipants(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipantModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
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