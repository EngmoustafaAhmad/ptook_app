import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/competitions/data/datasources/i_competition_remote_data_source.dart';
import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/data/models/team_model.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';

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
      throw ServerException(e.message ?? 'Failed to fetch public competitions');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Search query failed');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw const ServerException('User must be logged in');
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
      throw ServerException(e.message ?? 'Failed to fetch joined competitions');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw const ServerException('User must be logged in');
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
      throw ServerException(e.message ?? 'Failed to fetch created competitions');
    } catch (e) {
      throw ServerException(e.toString());
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
        throw const ServerException('Competition not found');
      }
      return _mapDocToModel(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get competition');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Failed to create competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateCompetition(CompetitionModel model) async {
    try {
      await _competitionsRef.doc(model.id).update(model.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCompetition(String competitionId) async {
    try {
      final compRef = _competitionsRef.doc(competitionId);
      final batch = firestore.batch();

      final participantsSnapshot = await compRef.collection('participants').get();
      for (var doc in participantsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final teamsSnapshot = await compRef.collection('teams').get();
      for (var teamDoc in teamsSnapshot.docs) {
        final membersSnapshot = await teamDoc.reference.collection('members').get();
        for (var memberDoc in membersSnapshot.docs) {
          batch.delete(memberDoc.reference);
        }
        batch.delete(teamDoc.reference);
      }

      batch.delete(compRef);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> joinCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to join');
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
      throw ServerException(e.message ?? 'Failed to join competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to leave');
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
      throw ServerException(e.message ?? 'Failed to leave competition');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Failed to get competition by code');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Failed to finish competition');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Failed to update participant points');
    } catch (e) {
      throw ServerException(e.toString());
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
      throw ServerException(e.message ?? 'Failed to remove participant');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ===========================================================================
  // TEAM MANAGEMENT ACTIONS
  // ===========================================================================

  @override
  Future<TeamModel> createTeam({
    required String competitionId,
    required String name,
    bool isPrivate = false,
    String? joinCode,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to create a team');
    }

    try {
      final teamDocRef = _competitionsRef
          .doc(competitionId)
          .collection('teams')
          .doc();

      final effectiveJoinCode = (joinCode != null && joinCode.trim().isNotEmpty)
          ? joinCode.trim()
          : teamDocRef.id.substring(0, 6).toUpperCase();

      final teamModel = TeamModel(
        id: teamDocRef.id,
        name: name,
        points: 0,
        members: const [],
        competitionId: competitionId,
        ownerId: user.uid,
        isPrivate: isPrivate,
        joinCode: effectiveJoinCode,
        createdAt: DateTime.now(),
      );

      await teamDocRef.set(teamModel.toJson());
      return teamModel;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create team');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTeam({
    required String competitionId,
    required String teamId,
  }) async {
    try {
      final teamDocRef = _competitionsRef
          .doc(competitionId)
          .collection('teams')
          .doc(teamId);

      final batch = firestore.batch();
      final membersSnapshot = await teamDocRef.collection('members').get();

      for (var doc in membersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(teamDocRef);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete team');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to join a team');
    }

    final teamRef = _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .doc(teamId);

    final participantRef = _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .doc(user.uid);

    return firestore.runTransaction((transaction) async {
      final teamSnap = await transaction.get(teamRef);
      final participantSnap = await transaction.get(participantRef);

      if (!teamSnap.exists) {
        throw const ServerException('Team not found');
      }

      final teamData = teamSnap.data()!;
      final isPrivate = teamData['isPrivate'] ?? false;
      final requiredCode = teamData['joinCode'] ?? '';

      if (isPrivate && (joinCode == null || joinCode.trim() != requiredCode)) {
        throw const ServerException('Invalid team join code');
      }

      Map<String, dynamic> memberMap;
      if (participantSnap.exists && participantSnap.data() != null) {
        final pData = participantSnap.data()!;
        memberMap = {
          'id': user.uid,
          'name': pData['name'] ?? user.displayName ?? 'Anonymous User',
          'avatarUrl': pData['avatarUrl'] ?? user.photoURL ?? '',
          'points': pData['points'] ?? 0,
          'joinedAt': pData['joinedAt'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        memberMap = {
          'id': user.uid,
          'name': user.displayName ?? 'Anonymous User',
          'avatarUrl': user.photoURL ?? '',
          'points': 0,
          'joinedAt': DateTime.now().toIso8601String(),
        };
      }

      final List<dynamic> rawMembers = teamData['members'] ?? [];
      final List<Map<String, dynamic>> members = rawMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      members.removeWhere((m) => m['id'] == user.uid);
      members.add(memberMap);

      transaction.update(teamRef, {
        'members': members,
      });

      transaction.set(teamRef.collection('members').doc(user.uid), memberMap);

      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': teamId,
        });
      }
    });
  }

  @override
  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to leave a team');
    }

    final teamRef = _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .doc(teamId);

    final participantRef = _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .doc(user.uid);

    return firestore.runTransaction((transaction) async {
      final teamSnap = await transaction.get(teamRef);
      if (!teamSnap.exists) {
        throw const ServerException('Team not found');
      }

      final teamData = teamSnap.data()!;
      final List<dynamic> rawMembers = teamData['members'] ?? [];
      final List<Map<String, dynamic>> members = rawMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      members.removeWhere((m) => m['id'] == user.uid);

      transaction.update(teamRef, {
        'members': members,
      });

      transaction.delete(teamRef.collection('members').doc(user.uid));

      final participantSnap = await transaction.get(participantRef);
      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': FieldValue.delete(),
        });
      }
    });
  }

  @override
  Future<void> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User not authenticated');
    }

    final fromRef = _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .doc(fromTeamId);

    final toRef = _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .doc(toTeamId);

    final participantRef = _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .doc(user.uid);

    return firestore.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);
      final participantSnap = await transaction.get(participantRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw const ServerException('Team does not exist');
      }

      final toData = toSnap.data()!;
      final isPrivate = toData['isPrivate'] ?? false;
      final requiredCode = toData['joinCode'] ?? '';

      if (isPrivate && (joinCode == null || joinCode.trim() != requiredCode)) {
        throw const ServerException('Invalid join code for target team');
      }

      Map<String, dynamic> memberMap;
      if (participantSnap.exists && participantSnap.data() != null) {
        final pData = participantSnap.data()!;
        memberMap = {
          'id': user.uid,
          'name': pData['name'] ?? user.displayName ?? 'Anonymous User',
          'avatarUrl': pData['avatarUrl'] ?? user.photoURL ?? '',
          'points': pData['points'] ?? 0,
          'joinedAt': pData['joinedAt'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        memberMap = {
          'id': user.uid,
          'name': user.displayName ?? 'Anonymous User',
          'avatarUrl': user.photoURL ?? '',
          'points': 0,
          'joinedAt': DateTime.now().toIso8601String(),
        };
      }

      // Remove from old team
      final fromData = fromSnap.data()!;
      final List<dynamic> rawFromMembers = fromData['members'] ?? [];
      final List<Map<String, dynamic>> fromMembers = rawFromMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();
      fromMembers.removeWhere((m) => m['id'] == user.uid);

      transaction.update(fromRef, {'members': fromMembers});
      transaction.delete(fromRef.collection('members').doc(user.uid));

      // Add to new team
      final List<dynamic> rawToMembers = toData['members'] ?? [];
      final List<Map<String, dynamic>> toMembers = rawToMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();
      toMembers.removeWhere((m) => m['id'] == user.uid);
      toMembers.add(memberMap);

      transaction.update(toRef, {'members': toMembers});
      transaction.set(toRef.collection('members').doc(user.uid), memberMap);

      // Update participant's active team pointer
      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': toTeamId,
        });
      }
    });
  }

  @override
  Future<void> removeMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  }) async {
    final teamRef = _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .doc(teamId);

    final participantRef = _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .doc(memberId);

    return firestore.runTransaction((transaction) async {
      final teamSnap = await transaction.get(teamRef);
      if (!teamSnap.exists) return;

      final teamData = teamSnap.data()!;
      final List<dynamic> rawMembers = teamData['members'] ?? [];
      final List<Map<String, dynamic>> members = rawMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      members.removeWhere((m) => m['id'] == memberId);

      transaction.update(teamRef, {'members': members});
      transaction.delete(teamRef.collection('members').doc(memberId));

      final participantSnap = await transaction.get(participantRef);
      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': FieldValue.delete(),
        });
      }
    });
  }

  @override
  Future<void> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  }) async {
    try {
      final teamRef = _competitionsRef
          .doc(competitionId)
          .collection('teams')
          .doc(teamId);

      final batch = firestore.batch();

      batch.update(teamRef.collection('members').doc(memberId), {
        'points': FieldValue.increment(points),
      });

      batch.update(teamRef, {
        'points': FieldValue.increment(points),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update member points');
    } catch (e) {
      throw ServerException(e.toString());
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
        .where((doc) => doc.exists && doc.data() != null)
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

  @override
  Stream<List<TeamModel>> streamTeams(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamModel.fromJson(
                  doc.data(),
                  doc.id,
                ))
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
      throw const ServerException('Competition document contains no data');
    }
    return CompetitionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}