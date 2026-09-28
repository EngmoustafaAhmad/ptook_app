import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/view_competition/data/datasources/competition/i_view_competition_remote_data_source.dart';

class ViewCompetitionRemoteDataSourceImpl
    implements IViewCompetitionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ViewCompetitionRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  DocumentReference<Map<String, dynamic>> _userDocRef(String userId) =>
      firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _userFavoritesRef(String userId) =>
      _userDocRef(userId).collection('favorites');

  @override
  Future<List<CompetitionModel>> getCompetitions() async {
    return getPublicCompetitions();
  }

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
      final competitions = snapshot.docs.map(_mapDocToModel).toList();
      return _attachFavoriteFlags(competitions);
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch public competitions',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompetitionModel> getCompetitionDetails({
    required String competitionId,
    required String userId,
  }) async {
    try {
      final compDoc = await _competitionsRef.doc(competitionId).get();
      if (!compDoc.exists || compDoc.data() == null) {
        throw const ServerException('Competition not found');
      }

      final favDoc = await _userFavoritesRef(userId).doc(competitionId).get();

      return CompetitionModel.fromJson(
        compDoc.data()!,
        id: compDoc.id,
        isFavorite: favDoc.exists,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch competition details');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  }) async {
    try {
      final batch = firestore.batch();
      final userRef = _userDocRef(userId);
      final favDocRef = _userFavoritesRef(userId).doc(competitionId);

      if (isFavorite) {
        // 1. Add document to favorites subcollection
        batch.set(favDocRef, {
          'competitionId': competitionId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Atomically update user document fields
        batch.update(userRef, {
          'savedCompetitionIds': FieldValue.arrayUnion([competitionId]),
          'savedCompetitionsCount': FieldValue.increment(1),
        });
      } else {
        // 1. Delete document from favorites subcollection
        batch.delete(favDocRef);

        // 2. Atomically update user document fields
        batch.update(userRef, {
          'savedCompetitionIds': FieldValue.arrayRemove([competitionId]),
          'savedCompetitionsCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update favorite status');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String competitionId,
  }) async {
    try {
      final docSnap = await _userFavoritesRef(userId).doc(competitionId).get();
      return docSnap.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getFavoriteCompetitionIds(String userId) async {
    try {
      final snapshot = await _userFavoritesRef(userId).get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch favorite competition IDs',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CompetitionModel>> getFavoriteCompetitions({
    String? userId,
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    final targetUserId = userId ?? auth.currentUser?.uid;

    if (targetUserId == null || targetUserId.isEmpty) {
      throw const ServerException('User must be logged in to fetch favorites');
    }

    try {
      Query<Map<String, dynamic>> favQuery = _userFavoritesRef(targetUserId)
          .orderBy(FieldPath.documentId);

      if (lastCompetitionId != null && lastCompetitionId.isNotEmpty) {
        final lastDoc =
            await _userFavoritesRef(targetUserId).doc(lastCompetitionId).get();
        if (lastDoc.exists) {
          favQuery = favQuery.startAfterDocument(lastDoc);
        }
      }

      final favSnap = await favQuery.limit(limit).get();
      if (favSnap.docs.isEmpty) return [];

      final favIds = favSnap.docs.map((doc) => doc.id).toList();

      final Map<String, CompetitionModel> compMap = {};
      for (var i = 0; i < favIds.length; i += 10) {
        final chunk = favIds.sublist(
          i,
          i + 10 > favIds.length ? favIds.length : i + 10,
        );

        final compSnap = await _competitionsRef
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in compSnap.docs) {
          final model = _mapDocToModel(doc);
          compMap[doc.id] = CompetitionModel.fromEntity(
            model.copyWith(isFavorite: true),
          );
        }
      }

      final List<CompetitionModel> sortedFavorites = [];
      for (final id in favIds) {
        if (compMap.containsKey(id)) {
          sortedFavorites.add(compMap[id]!);
        }
      }

      return sortedFavorites;
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch favorite competitions',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<String>> streamFavoriteCompetitionIds(String userId) {
    return _userFavoritesRef(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
        );
  }

  Future<List<CompetitionModel>> _attachFavoriteFlags(
    List<CompetitionModel> competitions,
  ) async {
    final user = auth.currentUser;
    if (user == null || competitions.isEmpty) return competitions;

    final favIds = (await getFavoriteCompetitionIds(user.uid)).toSet();

    return competitions.map((comp) {
      return CompetitionModel.fromEntity(
        comp.copyWith(isFavorite: favIds.contains(comp.id)),
      );
    }).toList();
  }

  @override
  Stream<CompetitionModel> streamCompetition({
    required String competitionId,
    required String userId,
  }) {
    return _competitionsRef
        .doc(competitionId)
        .snapshots()
        .where((doc) => doc.exists && doc.data() != null)
        .asyncMap((doc) async {
      final data = doc.data()!;

      final favDoc =
          await _userFavoritesRef(userId).doc(competitionId).get();

      return CompetitionModel.fromJson(
        data,
        id: doc.id,
        isFavorite: favDoc.exists,
      );
    });
  }

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
      throw const ServerException('Competition document contains no data');
    }
    return CompetitionModel.fromJson(
      data,
      id: doc.id,
    );
  }
}