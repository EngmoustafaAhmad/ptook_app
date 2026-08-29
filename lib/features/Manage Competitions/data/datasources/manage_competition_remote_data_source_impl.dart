import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../shared/data/models/participant_model.dart';
import '../../../shared/data/models/team_model.dart';
import 'i_manage_competition_remote_data_source.dart';

class ManageCompetitionRemoteDataSourceImpl
    implements IManageCompetitionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ManageCompetitionRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  // ===========================================================================
  // ORGANIZER DASHBOARD FETCHING
  // ===========================================================================

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
        firestoreQuery = firestoreQuery.where(
          'searchKeywords',
          arrayContains: cleanKeyword,
        );
      } else {
        firestoreQuery =
            firestoreQuery.orderBy('createdAt', descending: true);
      }

      firestoreQuery =
          await _applyPagination(firestoreQuery, lastCompetitionId);

      final snapshot = await firestoreQuery.limit(limit).get();
      return snapshot.docs.map(_mapDocToModel).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error in getCreatedCompetitions: ${e.message}');
      throw ServerException(
        e.message ?? 'Failed to fetch created competitions',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ===========================================================================
  // COMPETITION ADMINISTRATION
  // ===========================================================================

  @override
  Future<void> createCompetition(CompetitionModel competition) async {
    try {
      await _competitionsRef.doc(competition.id).set(competition.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create competition');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateCompetition(CompetitionModel competition) async {
    try {
      await _competitionsRef.doc(competition.id).update(competition.toJson());
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

      final participantsSnapshot =
          await compRef.collection('participants').get();
      for (var doc in participantsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final teamsSnapshot = await compRef.collection('teams').get();
      for (var teamDoc in teamsSnapshot.docs) {
        final membersSnapshot =
            await teamDoc.reference.collection('members').get();
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

  // ===========================================================================
  // PARTICIPANT MANAGEMENT
  // ===========================================================================

@override
Future<void> updateCompetitoinParticipantPoints({
  required String competitionId,
  required String participantId,
  required int addedPoints,
}) async {
  try {
    final participantsColl = _competitionsRef
        .doc(competitionId)
        .collection('participants');

    // 1. Check if participantId matches document ID directly
    final directDocRef = participantsColl.doc(participantId);
    final directSnap = await directDocRef.get();

    if (directSnap.exists) {
      await directDocRef.update({
        'points': FieldValue.increment(addedPoints),
        'totalPoints': FieldValue.increment(addedPoints),
      });
      return;
    }

    // 2. Fallback: Query by 'userId' field for legacy docs where docId != userId
    final querySnap = await participantsColl
        .where('userId', isEqualTo: participantId)
        .limit(1)
        .get();

    if (querySnap.docs.isNotEmpty) {
      await querySnap.docs.first.reference.update({
        'points': FieldValue.increment(addedPoints),
        'totalPoints': FieldValue.increment(addedPoints),
      });
      return;
    }

    throw ServerException('Participant document not found for ID: $participantId');
  } on FirebaseException catch (e) {
    throw ServerException(
      e.message ?? 'Failed to update participant points',
    );
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
  // TEAM ADMINISTRATION
  // ===========================================================================

  @override
  Future<void> createTeam(TeamEntity team) async {
    try {
      if (team.competitionId.trim().isEmpty) {
        throw ServerException('Competition ID cannot be empty');
      }

      final teamsCollection = _competitionsRef
          .doc(team.competitionId)
          .collection('teams');

      final docRef = team.id.trim().isNotEmpty
          ? teamsCollection.doc(team.id)
          : teamsCollection.doc();

      final updatedEntity = team.id.trim().isEmpty
          ? team.copyWith(id: docRef.id)
          : team;

      final model = TeamModel.fromEntity(updatedEntity);

      await docRef.set(model.toJson());
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


  // lib/features/Manage Competitions/data/datasources/team_remote_data_source_impl.dart


  @override
  Future<void> updateTeamParticipantPoints({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  }) async {
    final teamRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('teams')
        .doc(teamId);

    final participantRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(participantId);

    await firestore.runTransaction((transaction) async {
      // 1. Read both documents inside transaction
      final teamSnap = await transaction.get(teamRef);
      final participantSnap = await transaction.get(participantRef);

      if (!teamSnap.exists) return;

      // 2. Update standalone participant document (if present)
      if (participantSnap.exists) {
        final currentPts = (participantSnap.data()?['points'] as num?)?.toInt() ?? 
                           (participantSnap.data()?['totalPoints'] as num?)?.toInt() ?? 0;
        final newPts = currentPts + addedPoints;

        transaction.update(participantRef, {
          'points': newPts,
          'totalPoints': newPts,
        });
      }

      // 3. Update nested member entry in Team doc & recalculate total
      final teamData = teamSnap.data()!;
      final List<dynamic> membersRaw = teamData['members'] ?? [];
      int newTeamTotal = 0;

      final updatedMembers = membersRaw.map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        int memberPts = (map['points'] as num?)?.toInt() ?? 
                        (map['totalPoints'] as num?)?.toInt() ?? 0;

        if (map['id'] == participantId) {
          memberPts += addedPoints;
        }

        map['points'] = memberPts;
        map['totalPoints'] = memberPts;
        newTeamTotal += memberPts;

        return map;
      }).toList();

      transaction.update(teamRef, {
        'members': updatedMembers,
        'totalPoints': newTeamTotal,
        'points': newTeamTotal,
      });
    });
  }


@override
Future<void> removeTeamParticipant({
  required String competitionId,
  required String teamId,
  required String participantId,
}) async {
  try {
    final teamRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('teams')
        .doc(teamId);

    final participantRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(participantId);

    await firestore.runTransaction((transaction) async {
      // 1. ALL READS FIRST
      final teamSnap = await transaction.get(teamRef);
      final participantSnap = await transaction.get(participantRef);

      if (!teamSnap.exists) {
        throw Exception('Team document not found.');
      }

      final teamData = teamSnap.data() ?? {};
      final List<dynamic> currentMembers = List.from(teamData['members'] ?? []);

      int removedPoints = 0;

      // Filter out target participant and extract points
      final updatedMembers = currentMembers.where((m) {
        if (m is! Map) return false;
        final map = Map<String, dynamic>.from(m);
        final isMatch = map['id'] == participantId || map['userId'] == participantId;

        if (isMatch) {
          removedPoints = (map['points'] as num?)?.toInt() ??
                          (map['totalPoints'] as num?)?.toInt() ?? 0;
        }
        return !isMatch;
      }).toList();

      // Recalculate team total points safely
      final int currentTeamTotal = (teamData['totalPoints'] as num?)?.toInt() ??
                                   (teamData['points'] as num?)?.toInt() ?? 0;
      final int newTeamTotal = (currentTeamTotal - removedPoints).clamp(0, 999999);

      // 2. ALL WRITES AFTER ALL READS
      transaction.update(teamRef, {
        'members': updatedMembers,
        'totalPoints': newTeamTotal,
        'points': newTeamTotal,
      });

      if (participantSnap.exists) {
        transaction.update(participantRef, {
          'teamId': FieldValue.delete(),
        });
      }
    });
  } catch (e) {
    throw ServerException(e.toString());
  }
}

  // ===========================================================================
  // REAL-TIME STREAMS
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
      return CompetitionModel.fromJson(
        doc.data()!,
        doc.id,
      );
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
            .map((doc) => ParticipantModel.fromJson(
                  doc.data(),
                  doc.id,
                ))
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
    return CompetitionModel.fromJson(
      data,
      doc.id,
    );
  }


}