import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'i_search_competition_remote_data_source.dart';

class SearchCompetitionRemoteDataSourceImpl
    implements ISearchCompetitionRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SearchCompetitionRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;


  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      _firestore.collection('competitions');

  // ===========================================================================
  // QUERY BUILDERS
  // ===========================================================================

  Query<Map<String, dynamic>> _buildBaseFilterQuery({
    required CompetitionFilter compFilter,
    required String currentUserId,
  }) {
    Query<Map<String, dynamic>> query =
        _competitionsRef.where('status', isEqualTo: 'active');

    switch (compFilter) {
      case CompetitionFilter.all:
        break;
      case CompetitionFilter.joined:
        query = query.where('participantIds', arrayContains: currentUserId);
        break;
      case CompetitionFilter.myCreated:
        query = query.where('ownerId', isEqualTo: currentUserId);
        break;
    }

    return query;
  }

  // ===========================================================================
  // DISCOVERY & SEARCH (STREAM MODE VS SEARCH MODE)
  // ===========================================================================

  @override
  Stream<CompetitionPage<CompetitionModel>> streamActiveCompetitions({
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    Query<Map<String, dynamic>> query = _buildBaseFilterQuery(
      compFilter: filter,
      currentUserId: currentUserId,
    ).orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      final models = snapshot.docs
          .map((doc) => CompetitionModel.fromJson(doc.data(), id: doc.id))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = snapshot.docs.length >= limit;

      return CompetitionPage<CompetitionModel>(
        items: models,
        nextCursor: lastDoc != null ? CompetitionCursor(lastDoc) : null,
        hasMore: hasMore,
      );
    });
  }

  @override
  Future<CompetitionPage<CompetitionModel>> searchActiveCompetitions({
    required String query,
    required CompetitionFilter filter,
    required String currentUserId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    final cleanQuery = query.trim().toLowerCase();

    Query<Map<String, dynamic>> firestoreQuery = _buildBaseFilterQuery(
      compFilter: filter,
      currentUserId: currentUserId,
    );

    if (cleanQuery.isNotEmpty) {
      firestoreQuery =
          firestoreQuery.where('searchKeywords', arrayContains: cleanQuery);
    }

    firestoreQuery = firestoreQuery
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      firestoreQuery = firestoreQuery.startAfterDocument(startAfter);
    }

    final snapshot = await firestoreQuery.get();

    final models = snapshot.docs
        .map((doc) => CompetitionModel.fromJson(doc.data(), id: doc.id))
        .toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    final hasMore = snapshot.docs.length >= limit;

    return CompetitionPage<CompetitionModel>(
      items: models,
      nextCursor: lastDoc != null ? CompetitionCursor(lastDoc) : null,
      hasMore: hasMore,
    );
  }

}