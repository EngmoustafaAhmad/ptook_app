import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';
import 'package:ptook/features/view_competition/data/datasources/team/i_view_team_reamote_data_source.dart';

class ViewTeamRemoteDataSourceImpl implements IViewTeamReamoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ViewTeamRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<void> joinTeamCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be logged in to join');
    }

    try {
      final compDocRef = _competitionsRef.doc(competitionId);

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

      if (teamSnap != null && teamSnap.exists && teamSnap.data() != null) {
        final teamRef = compRef.collection('teams').doc(teamId);
        final List<dynamic> rawMembers = teamSnap.data()!['members'] ?? [];
        final List<Map<String, dynamic>> members = rawMembers
            .map((m) => Map<String, dynamic>.from(m as Map))
            .toList();

        members.removeWhere((m) => m['id'] == user.uid || m['userId'] == user.uid);

        final int totalPoints = members.fold<int>(
          0,
          (sum, m) => sum + ((m['points'] as num?)?.toInt() ?? 0),
        );

        transaction.update(teamRef, {
          'members': members,
          'membersCount': members.length,
          'totalPoints': totalPoints,
        });
        transaction.delete(teamRef.collection('members').doc(user.uid));
      }

      if (participantSnap.exists) {
        transaction.delete(participantRef);
      }

      final List<dynamic> participantIds = compSnap.data()?['participantIds'] ?? [];
      final bool wasParticipant = participantIds.contains(user.uid);

      transaction.update(compRef, {
        'participantIds': FieldValue.arrayRemove([user.uid]),
        if (wasParticipant) 'participantsCount': FieldValue.increment(-1),
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
          rawMembers.any((m) => (m as Map)['id'] == user.uid || (m as Map)['userId'] == user.uid);

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

      members.removeWhere((m) => m['id'] == user.uid || m['userId'] == user.uid);
      members.add(memberMap);

      final int totalPoints = members.fold<int>(
        0,
        (sum, m) => sum + ((m['points'] as num?)?.toInt() ?? 0),
      );

      transaction.update(teamRef, {
        'members': members,
        'membersCount': members.length,
        'totalPoints': totalPoints,
      });

      transaction.set(teamRef.collection('members').doc(user.uid), memberMap);

      // 1. Update or create participant document with current teamId
      if (participantSnap.exists) {
        transaction.update(participantRef, {'teamId': teamId});
      } else {
        transaction.set(participantRef, {
          'id': user.uid,
          'userId': user.uid,
          'competitionId': competitionId,
          'name': user.displayName ?? 'User_${user.uid.substring(0, 5)}',
          'avatarUrl': user.photoURL ?? '',
          'teamId': teamId,
          'points': 0,
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      // 2. Add user to competition array and increment participantsCount by 1
      transaction.update(competitionRef, {
        'participantIds': FieldValue.arrayUnion([user.uid]),
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

      members.removeWhere((m) => m['id'] == user.uid || m['userId'] == user.uid);

      final int totalPoints = members.fold<int>(
        0,
        (sum, m) => sum + ((m['points'] as num?)?.toInt() ?? 0),
      );

      // 1. Remove member from team document & team members sub-collection
      transaction.update(teamRef, {
        'members': members,
        'membersCount': members.length,
        'totalPoints': totalPoints,
      });

      transaction.delete(teamRef.collection('members').doc(user.uid));

      // 2. Remove participant document from competition
      if (participantSnap.exists) {
        transaction.delete(participantRef);
      }

      // 3. Remove user from competition array and decrement participantsCount by 1
      transaction.update(competitionRef, {
        'participantIds': FieldValue.arrayRemove([user.uid]),
        'participantsCount': FieldValue.increment(-1),
      });
    });
  }

  // ===========================================================================
  // REAL-TIME STREAMS
  // ===========================================================================

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

      teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      return teams;
    });
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  Map<String, dynamic> _buildMemberMap(
    User user,
    DocumentSnapshot<Map<String, dynamic>> participantSnap,
  ) {
    if (participantSnap.exists && participantSnap.data() != null) {
      final pData = participantSnap.data()!;
      return {
        'id': user.uid,
        'userId': user.uid,
        'name': pData['name'] ?? user.displayName ?? 'Anonymous User',
        'avatarUrl': pData['avatarUrl'] ?? user.photoURL ?? '',
        'points': pData['points'] ?? 0,
        'joinedAt': pData['joinedAt'] ?? Timestamp.now(),
      };
    }

    return {
      'id': user.uid,
      'userId': user.uid,
      'name': user.displayName ?? 'Anonymous User',
      'avatarUrl': user.photoURL ?? '',
      'points': 0,
      'joinedAt': Timestamp.now(),
    };
  }
}