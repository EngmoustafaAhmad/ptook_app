import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'i_search_competition_remote_data_source.dart';

class SearchCompetitionRemoteDataSourceImpl implements ISearchCompetitionRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SearchCompetitionRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      _firestore.collection('competitions');

  @override
Stream<List<CompetitionModel>> streamAllCompetitions({
  int limit = 10,
  String? lastCompetitionId,
}) {
  Query<Map<String, dynamic>> query = _competitionsRef
      .orderBy('createdAt', descending: true)
      .limit(limit);

  return query.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => CompetitionModel.fromJson(doc.data(), id:doc.id))
        .toList();
  });
}

@override
Stream<List<CompetitionModel>> streamSearchCompetitions({
  required String query,
  int limit = 10,
  String? lastCompetitionId,
}) {
  final cleanQuery = query.toLowerCase().trim();

  Query<Map<String, dynamic>> firebaseQuery = _competitionsRef
      .where('searchKeywords', arrayContains: cleanQuery)
      .orderBy('createdAt', descending: true)
      .limit(limit);

  return firebaseQuery.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => CompetitionModel.fromJson(doc.data(), id:doc.id))
        .toList();
  });
}

  @override
Stream<List<CompetitionModel>> streamJoinedCompetitions({
  String? query,
  int limit = 10,
  String? lastCompetitionId,
}) {
  Query<Map<String, dynamic>> firebaseQuery = _competitionsRef
      .where('participantIds', arrayContains: _currentUserId)
      .orderBy('createdAt', descending: true);

  return firebaseQuery.snapshots().map((snapshot) {
    // 1. Map raw documents to models
    var competitions = snapshot.docs
        .map((doc) => CompetitionModel.fromJson(doc.data(), id:doc.id))
        .toList();

    // 2. Perform local text filtering if query is provided
    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();

      competitions = competitions.where((comp) {
        final matchesName = comp.name.toLowerCase().contains(cleanQuery);
        
        // Null-safe keyword check
        final matchesKeywords = comp.searchKeywords.any(
          (keyword) => keyword.toLowerCase().contains(cleanQuery),
        );

        return matchesName || matchesKeywords;
      }).toList();
    }

    // 3. Apply pagination limit after local filtering
    return competitions.take(limit).toList();
  });
}

  @override
  Stream<List<CompetitionModel>> streamCreatedCompetitions({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    Query<Map<String, dynamic>> firebaseQuery = _competitionsRef
        .where('ownerId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true);

    if (query != null && query.isNotEmpty) {
      firebaseQuery = firebaseQuery.where(
        'searchKeywords',
        arrayContains: query.toLowerCase().trim(),
      );
    }

    return firebaseQuery.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CompetitionModel.fromJson(doc.data(), id:doc.id))
          .toList();
    });
  }

  @override
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String? joinCode,
  }) async {
    final compRef = _competitionsRef.doc(competitionId);
    final participantRef = compRef.collection('participants').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final compDoc = await transaction.get(compRef);
      if (!compDoc.exists) {
        throw Exception('Competition not found');
      }

      final data = compDoc.data()!;
      final bool isPublic = data['isPublic'] ?? true;
      final String? expectedCode = data['joinCode'] ?? data['code'];
      final List<dynamic> participantIds = data['participantIds'] ?? [];

      // Check if user is already a participant
      if (participantIds.contains(userId)) {
        return;
      }

      // Validate access code for private competitions
      if (!isPublic) {
        if (joinCode == null || joinCode.trim().isEmpty) {
          throw Exception('Join code is required for private competitions');
        }
        if (expectedCode != null && expectedCode.trim() != joinCode.trim()) {
          throw Exception('Invalid join code');
        }
      }

      // Update parent competition document
      transaction.update(compRef, {
        'participantIds': FieldValue.arrayUnion([userId]),
        'participantsCount': FieldValue.increment(1),
      });

      // Add participant record to subcollection
      transaction.set(participantRef, {
        'userId': userId,
        'competitionId': competitionId,
        'role': 'member',
        'points': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveCompetition(String competitionId) async {
    final compRef = _competitionsRef.doc(competitionId);
    final participantRef = compRef.collection('participants').doc(_currentUserId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(compRef);
      if (!snapshot.exists) throw Exception('Competition not found');

      transaction.update(compRef, {
        'participantIds': FieldValue.arrayRemove([_currentUserId]),
        'participantsCount': FieldValue.increment(-1),
      });

      transaction.delete(participantRef);
    });
  }

  @override
  Future<void> createCompetition(CompetitionModel competition) async {
    final docRef = _competitionsRef.doc();
    final data = competition.toJson();
    data['id'] = docRef.id;
    data['ownerId'] = _currentUserId;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
  }

  @override
  Future<void> updateCompetition(CompetitionModel competition) async {
    await _competitionsRef
        .doc(competition.id)
        .update(competition.toJson());
  }

  @override
  Future<void> deleteCompetition(String competitionId) async {
    await _competitionsRef.doc(competitionId).delete();
  }

  @override
  Future<void> finishCompetition(String competitionId) async {
    await _competitionsRef.doc(competitionId).update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<CompetitionModel?> getCompetitionByCode(String code) async {
    final snapshot = await _competitionsRef
        .where('code', isEqualTo: code.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return CompetitionModel.fromJson(doc.data(), id:doc.id);
  }

  @override
  Future<CompetitionModel> getCompetitionById(String competitionId) async {
    final doc = await _competitionsRef.doc(competitionId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Competition not found');
    }
    return CompetitionModel.fromJson(doc.data()!, id:doc.id);
  }

  @override
  Future<CompetitionModel> getCompetitionDetails(String competitionId) async {
    return getCompetitionById(competitionId);
  }

  @override
  Future<List<ParticipantEntity>> getParticipants(String competitionId) async {
    final snapshot = await _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ParticipantEntity(
        id: doc.id,
        userId: data['userId'] ?? '',
        name: data['name'] ?? '',
        teamId: data['teamId'],
        competitionId: data['competitionId'] ?? competitionId,
        role: data['role'] ?? 'member',
        points: (data['points'] as num?)?.toInt() ?? 0,
        joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ParticipantEntity(
          id: doc.id,
          userId: data['userId'] ?? '',
          name: data['name'] ?? '',
          teamId: data['teamId'],
          competitionId: data['competitionId'] ?? competitionId,
          role: data['role'] ?? 'member',
          points: (data['points'] as num?)?.toInt() ?? 0,
          joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Stream<List<TeamEntity>> streamTeams(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TeamModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}