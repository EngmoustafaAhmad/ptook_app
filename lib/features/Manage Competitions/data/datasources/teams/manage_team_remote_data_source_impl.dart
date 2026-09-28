import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/teams/i_manage_team_remote_data_source.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';

class ManageTeamRemoteDataSourceImpl
    implements IManageTeamRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ManageTeamRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<void> createTeam(TeamModel team) async {
    try {
      if (team.competitionId.trim().isEmpty) {
        throw const ServerException('Competition ID cannot be empty');
      }

      final compDocRef = _competitionsRef.doc(team.competitionId);
      final teamsCollection = compDocRef.collection('teams');

      final docRef = team.id.trim().isNotEmpty
          ? teamsCollection.doc(team.id)
          : teamsCollection.doc();

      final updatedModel = team.id.trim().isEmpty
          ? team.copyWith(id: docRef.id) as TeamModel
          : team;

      final batch = firestore.batch();
      
      batch.set(docRef, updatedModel.toJson());
      batch.update(compDocRef, {
        'teamIds': FieldValue.arrayUnion([docRef.id]),
      });

      await batch.commit();
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
      final compDocRef = _competitionsRef.doc(competitionId);
      final teamDocRef = compDocRef.collection('teams').doc(teamId);

      final batch = firestore.batch();
      final membersSnapshot = await teamDocRef.collection('members').get();

      for (var doc in membersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      batch.delete(teamDocRef);
      batch.update(compDocRef, {
        'teamIds': FieldValue.arrayRemove([teamId]),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete team');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTeamParticipantPoints({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  }) async {
    try {
      final teamRef = _competitionsRef.doc(competitionId).collection('teams').doc(teamId);
      final participantRef = _competitionsRef.doc(competitionId).collection('participants').doc(participantId);

      await firestore.runTransaction((transaction) async {
        final teamSnap = await transaction.get(teamRef);
        final participantSnap = await transaction.get(participantRef);

        if (!teamSnap.exists) return;

        if (participantSnap.exists) {
          final currentPts = (participantSnap.data()?['points'] as num?)?.toInt() ?? 
                             (participantSnap.data()?['totalPoints'] as num?)?.toInt() ?? 0;
          final newPts = currentPts + addedPoints;

          transaction.update(participantRef, {
            'points': newPts,
            'totalPoints': newPts,
          });
        }

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
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update team participant points');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeTeamParticipant({
    required String competitionId,
    required String teamId,
    required String participantId,
  }) async {
    try {
      final compDocRef = _competitionsRef.doc(competitionId);
      final teamRef = compDocRef.collection('teams').doc(teamId);
      final participantRef = compDocRef.collection('participants').doc(participantId);

      await firestore.runTransaction((transaction) async {
        final teamSnap = await transaction.get(teamRef);
        final participantSnap = await transaction.get(participantRef);

        if (!teamSnap.exists) {
          throw const ServerException('Team document not found.');
        }

        final teamData = teamSnap.data() ?? {};
        final List<dynamic> currentMembers = List.from(teamData['members'] ?? []);

        int removedPoints = 0;

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

        final int currentTeamTotal = (teamData['totalPoints'] as num?)?.toInt() ??
                                     (teamData['points'] as num?)?.toInt() ?? 0;
        final int newTeamTotal = (currentTeamTotal - removedPoints).clamp(0, 999999);

        // 1. Update team members list, count, and totals
        transaction.update(teamRef, {
          'members': updatedMembers,
          'membersCount': updatedMembers.length,
          'totalPoints': newTeamTotal,
          'points': newTeamTotal,
        });

        // 2. Delete participant document from sub-collection
        if (participantSnap.exists) {
          transaction.delete(participantRef);
        }

        // 3. Decrement competition participants count & remove participantId
        transaction.update(compDocRef, {
          'participantIds': FieldValue.arrayRemove([participantId]),
          'participantsCount': FieldValue.increment(-1),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to remove team participant');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<TeamModel>> streamTeams(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('teams')
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => TeamModel.fromJson(
                    doc.data(),
                    doc.id,
                  ))
              .toList();

          // Sort in-memory to prevent missing field exclusions and Firestore index requirements
          teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
          return teams;
        });
  }
}