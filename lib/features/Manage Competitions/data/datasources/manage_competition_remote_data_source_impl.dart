import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptook/features/shared/data/models/competition_model.dart';
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
  Future<void> createTeam(TeamModel team) async {
    try {
      await _competitionsRef
          .doc(team.competitionId)
          .collection('teams')
          .doc(team.id)
          .set(team.toJson());
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