import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 Added Firebase Auth

import '../../domain/entities/podium_tier.dart';
import '../models/participant_model.dart';
import 'participant_remote_data_source.dart';

class ParticipantRemoteDataSourceImpl implements IParticipantRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth; // 🌟 Injected Auth instance

  ParticipantRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  }) async {
    final competitionRef = firestore.collection('competitions').doc(competitionId);
    final participantRef = competitionRef.collection('participants').doc(userId);
    final userRef = firestore.collection('users').doc(userId); // 🌟 To read user data

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(competitionRef);

      if (!snapshot.exists) {
        throw Exception('Competition no longer exists');
      }

      // 🌟 Fetch user doc inside transaction (or fallback to Auth currentUser)
      final userSnapshot = await transaction.get(userRef);
      final currentUser = auth.currentUser;

      // Extract registered name
      final userName = userSnapshot.data()?['name'] ?? 
          currentUser?.displayName ?? 
          'Participant';

      final userAvatar = userSnapshot.data()?['avatarUrl'] ?? 
          currentUser?.photoURL;

      final data = snapshot.data();
      final currentCount = data?['participantsCount'] ?? 0;
      final maxParticipants = data?['maxParticipants'] ?? 0;
      final participantIds = List<String>.from(data?['participantIds'] ?? []);

      // 1. Check if user is already joined
      if (participantIds.contains(userId)) {
        throw Exception('You are already a participant in this competition!');
      }

      // 2. Capacity Check
      if (maxParticipants > 0 && currentCount >= maxParticipants) {
        throw Exception('This competition has reached max capacity!');
      }

      // 3. Add to participants sub-collection WITH NAME & AVATAR
      transaction.set(participantRef, {
        'userId': userId,
        'competitionId': competitionId,
        'name': userName,         // 👈 🌟 Saved to participant document!
        'avatarUrl': userAvatar,   // 👈 🌟 Saved to participant document!
        'role': role,
        'teamId': teamId,
        'points': 0,
        'joinedAt': FieldValue.serverTimestamp(),
        'rank': 0,
      });

      // 4. Increment counter and append participantId atomically
      transaction.update(competitionRef, {
        'participantsCount': FieldValue.increment(1),
        'participantIds': FieldValue.arrayUnion([userId]),
      });
    });
  }

  @override
  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  }) async {
    final competitionRef = firestore.collection('competitions').doc(competitionId);
    final participantRef = competitionRef.collection('participants').doc(userId);

    return firestore.runTransaction((transaction) async {
      final participantDoc = await transaction.get(participantRef);

      if (!participantDoc.exists) {
        throw Exception('User is not a participant in this competition');
      }

      // 1. Remove participant document from sub-collection
      transaction.delete(participantRef);

      // 2. Decrement total count and remove participantId atomically
      transaction.update(competitionRef, {
        'participantsCount': FieldValue.increment(-1),
        'participantIds': FieldValue.arrayRemove([userId]),
      });
    });
  }

  @override
  Future<List<ParticipantModel>> getCompetitionParticipants(
    String competitionId,
  ) async {
    final snapshot = await firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .orderBy('points', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ParticipantModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> updatePoints({
    required String competitionId,
    required String userId,
    required int points,
  }) async {
    final participantRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(userId);

    await participantRef.update({
      'points': FieldValue.increment(points),
    });
  }

  @override
  Future<void> assignPodiumStars({
    required String competitionId,
    required String userId,
    required int rank,
  }) async {
    final participantRef = firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(userId);

    final userRef = firestore.collection('users').doc(userId);

    final podiumTier = PodiumTier.fromRank(rank);
    final starsToAward = podiumTier.stars;

    return firestore.runTransaction((transaction) async {
      // 1. Set rank on the participant document
      transaction.update(participantRef, {
        'rank': rank,
      });

      // 2. Increment lifetime stars on the user's overall profile
      if (starsToAward > 0) {
        transaction.update(userRef, {
          'totalStarsEarned': FieldValue.increment(starsToAward),
        });
      }
    });
  }
}