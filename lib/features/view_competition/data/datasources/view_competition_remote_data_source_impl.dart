import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/data/models/participant_model.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';
import '../../../../core/errors/exceptions.dart';
import 'i_view_competition_remote_data_source.dart';

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

  CollectionReference<Map<String, dynamic>> _userFavoritesRef(String userId) =>
      firestore.collection('users').doc(userId).collection('favorites');

  // ===========================================================================
  // DISCOVERY & FETCHING
  // ===========================================================================

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
      debugPrint('Firestore Error in getPublicCompetitions: ${e.message}');
      throw ServerException(
        e.message ?? 'Failed to fetch public competitions',
      );
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
      return getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
    }

    try {
      Query<Map<String, dynamic>> firestoreQuery = _competitionsRef
          .where('isPublic', isEqualTo: true)
          .where('searchKeywords', arrayContains: cleanQuery);

      firestoreQuery =
          await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      final competitions = snapshot.docs.map(_mapDocToModel).toList();
      return _attachFavoriteFlags(competitions);
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

      firestoreQuery =
          await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      var competitions = snapshot.docs.map(_mapDocToModel).toList();

      final cleanKeyword = query?.trim().toLowerCase() ?? '';
      if (cleanKeyword.isNotEmpty) {
        competitions = competitions
            .where((comp) => comp.name.toLowerCase().contains(cleanKeyword))
            .toList();
      }

      return _attachFavoriteFlags(competitions);
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getJoinedCompetitions: ${e.message}');
      throw ServerException(
        e.message ?? 'Failed to fetch joined competitions',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompetitionModel> getCompetitionById(String competitionId) async {
    try {
      final doc = await _competitionsRef.doc(competitionId).get();
      if (!doc.exists) {
        throw const ServerException('Competition not found');
      }

      var model = _mapDocToModel(doc);
      final user = auth.currentUser;
      if (user != null) {
        final favDoc =
            await _userFavoritesRef(user.uid).doc(competitionId).get();
        if (favDoc.exists) {
          model = CompetitionModel.fromEntity(
            model.copyWith(isFavorite: true),
          );
        }
      }

      return model;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get competition');
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
      // 1. Fetch competition document
      final compDoc = await _competitionsRef.doc(competitionId).get();
      if (!compDoc.exists || compDoc.data() == null) {
        throw const ServerException('Competition not found');
      }

      // 2. Check if this user has favorited this competition
      final favDoc = await _userFavoritesRef(userId).doc(competitionId).get();

      // 3. Return Model with actual isFavorite status from DB
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
  Future<CompetitionModel?> getCompetitionByCode(String code) async {
    try {
      final snapshot = await _competitionsRef
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      var model = _mapDocToModel(snapshot.docs.first);
      final user = auth.currentUser;
      if (user != null) {
        final favDoc =
            await _userFavoritesRef(user.uid).doc(model.id).get();
        if (favDoc.exists) {
          model = CompetitionModel.fromEntity(
            model.copyWith(isFavorite: true),
          );
        }
      }

      return model;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get competition by code');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ===========================================================================
  // FAVORITES ACTIONS
  // ===========================================================================

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  }) async {
    try {
      final favDocRef = _userFavoritesRef(userId).doc(competitionId);

      if (isFavorite) {
        await favDocRef.set({
          'competitionId': competitionId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await favDocRef.delete();
      }
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
  // Use passed userId, or fallback to authenticated currentUser
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



  // ===========================================================================
  // PARTICIPANT ACTIONS
  // ===========================================================================

  @override
  Future<void> joinIndividualCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to join');
    }

    try {
      final batch = firestore.batch();
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef =
          compDocRef.collection('participants').doc(user.uid);

      // Increments participantsCount and adds user to participantIds
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
  Future<void> leaveIndividualCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to leave');
    }

    try {
      final batch = firestore.batch();
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef =
          compDocRef.collection('participants').doc(user.uid);

      // Decrements participantsCount and removes user from participantIds
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
  Future<void> joinTeamCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to join');
    }

    try {
      final compDocRef = _competitionsRef.doc(competitionId);

      // Adds user to participantIds (Does NOT increment participantsCount)
      await compDocRef.update({
        'participantIds': FieldValue.arrayUnion([user.uid]),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to join team competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveTeamCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to leave');
    }

    final compRef = _competitionsRef.doc(competitionId);
    final participantRef = compRef.collection('participants').doc(user.uid);

    return firestore.runTransaction((transaction) async {
      // 1. ALL READS FIRST
      final compSnap = await transaction.get(compRef);
      if (!compSnap.exists) throw const ServerException('Competition not found');

      final participantSnap = await transaction.get(participantRef);
      String? teamId;

      if (participantSnap.exists && participantSnap.data() != null) {
        teamId = participantSnap.data()!['teamId'];
      }

      DocumentSnapshot<Map<String, dynamic>>? teamSnap;
      if (teamId != null && teamId.isNotEmpty) {
        teamSnap = await transaction.get(compRef.collection('teams').doc(teamId));
      }

      // 2. ALL WRITES
      if (teamSnap != null && teamSnap.exists && teamSnap.data() != null) {
        final teamRef = compRef.collection('teams').doc(teamId);
        final List<dynamic> rawMembers = teamSnap.data()!['members'] ?? [];
        final List<Map<String, dynamic>> members = rawMembers
            .map((m) => Map<String, dynamic>.from(m as Map))
            .toList();

        members.removeWhere((m) => m['id'] == user.uid);

        transaction.update(teamRef, {
          'members': members,
          'membersCount': members.length,
        });
        transaction.delete(teamRef.collection('members').doc(user.uid));
      }

      if (participantSnap.exists) {
        transaction.delete(participantRef);
      }

      // Removes user from participantIds (Does NOT decrement participantsCount)
      transaction.update(compRef, {
        'participantIds': FieldValue.arrayRemove([user.uid]),
      });
    });
  }

  // ===========================================================================
  // TEAM INTERACTION ACTIONS
  // ===========================================================================

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

    final competitionRef = _competitionsRef.doc(competitionId);
    final teamRef = competitionRef.collection('teams').doc(teamId);
    final participantRef =
        competitionRef.collection('participants').doc(user.uid);

    return firestore.runTransaction((transaction) async {
      // 1. ALL READS FIRST
      final compSnap = await transaction.get(competitionRef);
      final teamSnap = await transaction.get(teamRef);
      final participantSnap = await transaction.get(participantRef);

      if (!compSnap.exists) throw const ServerException('Competition not found');
      if (!teamSnap.exists) throw const ServerException('Team not found');

      final teamData = teamSnap.data()!;
      final isPrivate = teamData['isPrivate'] ?? false;
      final requiredCode = teamData['joinCode'] ?? '';

      if (isPrivate && (joinCode == null || joinCode.trim() != requiredCode)) {
        throw const ServerException('Invalid team join code');
      }

      final rawMembers = List<dynamic>.from(teamData['members'] ?? []);
      final int? maxMembers = (teamData['maxMembers'] as num?)?.toInt();
      final bool alreadyInTeam =
          rawMembers.any((m) => (m as Map)['id'] == user.uid);

      if (!alreadyInTeam &&
          maxMembers != null &&
          maxMembers > 0 &&
          rawMembers.length >= maxMembers) {
        throw const ServerException('This team has reached its maximum capacity');
      }

      final memberMap = _buildMemberMap(user, participantSnap);
      final List<Map<String, dynamic>> members = rawMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      members.removeWhere((m) => m['id'] == user.uid);
      members.add(memberMap);

      // 2. ALL WRITES
      // Updates team members list and increments membersCount
      transaction.update(teamRef, {
        'members': members,
        'membersCount': members.length,
      });

      transaction.set(teamRef.collection('members').doc(user.uid), memberMap);

      if (participantSnap.exists) {
        transaction.update(participantRef, {'teamId': teamId});
      }

      // Increments competition participantsCount
      transaction.update(competitionRef, {
        'participantsCount': FieldValue.increment(1),
      });
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

    final competitionRef = _competitionsRef.doc(competitionId);
    final teamRef = competitionRef.collection('teams').doc(teamId);
    final participantRef =
        competitionRef.collection('participants').doc(user.uid);

    return firestore.runTransaction((transaction) async {
      // 1. ALL READS FIRST
      final compSnap = await transaction.get(competitionRef);
      final teamSnap = await transaction.get(teamRef);
      final participantSnap = await transaction.get(participantRef);

      if (!compSnap.exists) throw const ServerException('Competition not found');
      if (!teamSnap.exists) throw const ServerException('Team not found');

      final teamData = teamSnap.data()!;
      final List<dynamic> rawMembers = teamData['members'] ?? [];
      final List<Map<String, dynamic>> members = rawMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      members.removeWhere((m) => m['id'] == user.uid);

      // 2. ALL WRITES
      // Updates team members list and decrements membersCount
      transaction.update(teamRef, {
        'members': members,
        'membersCount': members.length,
      });

      transaction.delete(teamRef.collection('members').doc(user.uid));

      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': FieldValue.delete(),
        });
      }

      // Decrements competition participantsCount
      transaction.update(competitionRef, {
        'participantsCount': FieldValue.increment(-1),
      });
    });
  }

  @override
  Future<void> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    if (fromTeamId == toTeamId) return;

    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User not authenticated');
    }

    final competitionRef = _competitionsRef.doc(competitionId);
    final fromRef = competitionRef.collection('teams').doc(fromTeamId);
    final toRef = competitionRef.collection('teams').doc(toTeamId);
    final participantRef =
        competitionRef.collection('participants').doc(user.uid);

    return firestore.runTransaction((transaction) async {
      // 1. ALL READS FIRST
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);
      final participantSnap = await transaction.get(participantRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw const ServerException('One or both teams do not exist');
      }

      final toData = toSnap.data()!;
      final isPrivate = toData['isPrivate'] ?? false;
      final requiredCode = toData['joinCode'] ?? '';

      if (isPrivate && (joinCode == null || joinCode.trim() != requiredCode)) {
        throw const ServerException('Invalid join code for target team');
      }

      final rawToMembers = List<dynamic>.from(toData['members'] ?? []);
      final int? maxMembers = (toData['maxMembers'] as num?)?.toInt();
      if (maxMembers != null &&
          maxMembers > 0 &&
          rawToMembers.length >= maxMembers) {
        throw const ServerException('Target team is full');
      }

      final memberMap = _buildMemberMap(user, participantSnap);

      final fromData = fromSnap.data()!;
      final List<dynamic> rawFromMembers = fromData['members'] ?? [];
      final List<Map<String, dynamic>> fromMembers = rawFromMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      fromMembers.removeWhere((m) => m['id'] == user.uid);

      final List<Map<String, dynamic>> toMembers = rawToMembers
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      toMembers.removeWhere((m) => m['id'] == user.uid);
      toMembers.add(memberMap);

      // 2. ALL WRITES
      // Updates both old and new team members lists & membersCount.
      // Does NOT touch competition participantsCount.
      transaction.update(fromRef, {
        'members': fromMembers,
        'membersCount': fromMembers.length,
      });
      transaction.delete(fromRef.collection('members').doc(user.uid));

      transaction.update(toRef, {
        'members': toMembers,
        'membersCount': toMembers.length,
      });
      transaction.set(toRef.collection('members').doc(user.uid), memberMap);

      if (participantSnap.exists) {
        transaction.update(participantRef, {'teamId': toTeamId});
      }
    });
  }
  // ===========================================================================
  // REAL-TIME STREAMS
  // ===========================================================================

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

    // Check if the user favorited this competition
    final favDoc =
        await _userFavoritesRef(userId).doc(competitionId).get();

    return CompetitionModel.fromJson(
      data,
      id: doc.id, // Fixed: Passed as named argument
      isFavorite: favDoc.exists, // Preserves favorited state
    );
  });
}

  @override
  Stream<List<ParticipantModel>> streamParticipants(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .snapshots()
        .map((snapshot) {
      final participants = snapshot.docs
          .map((doc) => ParticipantModel.fromJson(
                doc.data(),
                doc.id,
              ))
          .toList();

      // Sort locally by points descending
      participants.sort((a, b) => b.points.compareTo(a.points));

      return participants;
    });
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

  Map<String, dynamic> _buildMemberMap(
    User user,
    DocumentSnapshot<Map<String, dynamic>> participantSnap,
  ) {
    if (participantSnap.exists && participantSnap.data() != null) {
      final pData = participantSnap.data()!;
      return {
        'id': user.uid,
        'name': pData['name'] ?? user.displayName ?? 'Anonymous User',
        'avatarUrl': pData['avatarUrl'] ?? user.photoURL ?? '',
        'points': pData['points'] ?? 0,
        'joinedAt': pData['joinedAt'] ?? DateTime.now().toIso8601String(),
      };
    }

    return {
      'id': user.uid,
      'name': user.displayName ?? 'Anonymous User',
      'avatarUrl': user.photoURL ?? '',
      'points': 0,
      'joinedAt': DateTime.now().toIso8601String(),
    };
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

  @override
  Future<List<ParticipantModel>> getParticipants(String competitionId) async {
    try {
      final snapshot = await _competitionsRef
          .doc(competitionId)
          .collection('participants')
          .orderBy('points', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ParticipantModel.fromJson(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getParticipants: ${e.message}');
      throw ServerException(
        e.message ?? 'Failed to fetch participants',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }



  
}