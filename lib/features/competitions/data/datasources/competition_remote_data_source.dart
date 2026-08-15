import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';

abstract class ICompetitionRemoteDataSource {
  Future<List<CompetitionModel>> getCompetitions();
  Future<CompetitionModel> getCompetitionById(String competitionId);
  Future<CompetitionModel> getCompetitionDetails(String competitionId);
  Future<CompetitionModel?> getCompetitionByCode(String code);
  Future<void> createCompetition(CompetitionModel competition);
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> joinCompetition(String competitionId);
  Future<void> leaveCompetition(String competitionId);

  // Management Actions
  Future<void> finishCompetition(String competitionId);
  Future<void> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });
  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  // Paginated Fetching & Search
  Future<List<CompetitionModel>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

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

  // ===========================================================================
  // PAGINATED FETCHING & FILTERS
  // ===========================================================================

  @override
  Future<List<CompetitionModel>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _competitionsRef
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      query = await _applyPagination(query, lastCompetitionId);

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getPublicCompetitions: ${e.message}');
      throw ServerException(message: e.message ?? 'Failed to fetch public competitions');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return getPublicCompetitions(limit: limit, lastCompetitionId: lastCompetitionId);
    }

    try {
      Query<Map<String, dynamic>> firestoreQuery = _competitionsRef
          .where('isPublic', isEqualTo: true)
          .where('searchKeywords', arrayContains: cleanQuery);

      firestoreQuery = await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Search query failed');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User must be logged in');
    }

    try {
      Query<Map<String, dynamic>> firestoreQuery = _competitionsRef
          .where('participantIds', arrayContains: user.uid)
          .orderBy('createdAt', descending: true);

      firestoreQuery = await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      final competitions = snapshot.docs.map(_mapDocToModel).toList();

      final cleanKeyword = query?.trim().toLowerCase() ?? '';
      if (cleanKeyword.isNotEmpty) {
        return competitions
            .where((comp) => comp.name.toLowerCase().contains(cleanKeyword))
            .toList();
      }

      return competitions;
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getJoinedCompetitions: ${e.message}');
      throw ServerException(message: e.message ?? 'Failed to fetch joined competitions');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException(message: 'User must be logged in');
    }

    try {
      final cleanKeyword = query?.trim().toLowerCase() ?? '';
      Query<Map<String, dynamic>> firestoreQuery =
          _competitionsRef.where('ownerId', isEqualTo: user.uid);

      if (cleanKeyword.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('searchKeywords', arrayContains: cleanKeyword);
      } else {
        firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
      }

      firestoreQuery = await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getCreatedCompetitions: ${e.message}');
      throw ServerException(message: e.message ?? 'Failed to fetch created competitions');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ===========================================================================
  // CRUD & PARTICIPATION ACTIONS
  // ===========================================================================

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
  Future<CompetitionModel> getCompetitionDetails(String competitionId) async {
    return getCompetitionById(competitionId);
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
    final compRef = firestore.collection('competitions').doc(competitionId);

    // 1. Fetch all documents inside the 'participants' subcollection
    final participantsSnapshot = await compRef.collection('participants').get();

    // 2. Initialize a WriteBatch to execute all deletions together atomically
    final batch = firestore.batch();

    // 3. Add each participant document deletion to the batch
    for (var doc in participantsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 4. Add the parent competition document deletion to the batch
    batch.delete(compRef);

    // 5. Commit all deletions at once
    await batch.commit();
  } catch (e) {
    throw Exception('Failed to delete competition: $e');
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

      batch.update(compDocRef, {
        'participantIds': FieldValue.arrayUnion([user.uid]),
        'participantsCount': FieldValue.increment(1),
      });

      final participantModel = ParticipantModel(
        id: user.uid,
        userId: user.uid,
        competitionId: competitionId,
        name: user.displayName ?? 'Anonymous User',
        avatarUrl: user.photoURL ?? '',
        points: 0,
        role: 'participant',
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

      batch.update(compDocRef, {
        'participantIds': FieldValue.arrayRemove([user.uid]),
        'participantsCount': FieldValue.increment(-1),
      });

      batch.delete(participantDocRef);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to leave competition');
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

  // ===========================================================================
  // MANAGEMENT ACTIONS
  // ===========================================================================

  @override
  Future<void> finishCompetition(String competitionId) async {
    try {
      await _competitionsRef.doc(competitionId).update({
        'status': 'completed',
        'endDate': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to finish competition');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    try {
      await _competitionsRef
          .doc(competitionId)
          .collection('participants')
          .doc(participantId)
          .update({
        'points': FieldValue.increment(addedPoints),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to update participant points');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  }) async {
    try {
      final batch = firestore.batch();
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef =
          compDocRef.collection('participants').doc(participantId);

      batch.update(compDocRef, {
        'participantIds': FieldValue.arrayRemove([participantId]),
        'participantsCount': FieldValue.increment(-1),
      });

      batch.delete(participantDocRef);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to remove participant');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================


  @override
  Stream<CompetitionModel> streamCompetition(String competitionId) {
    return firestore
        .collection('competitions')
        .doc(competitionId)
        .snapshots()
        .where((doc) => doc.exists && doc.data() != null) // Filters out deleted snapshots
        .map((doc) {
          final data = doc.data()!;
          data['id'] = doc.id;
          return CompetitionModel.fromJson(data);
        });
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

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  Future<Query<Map<String, dynamic>>> _applyPagination(
    Query<Map<String, dynamic>> query,
    String? lastCompetitionId,
  ) async {
    if (lastCompetitionId == null || lastCompetitionId.isEmpty) {
      return query;
    }

    final lastDoc = await _competitionsRef.doc(lastCompetitionId).get();
    if (lastDoc.exists) {
      return query.startAfterDocument(lastDoc);
    }

    return query;
  }

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