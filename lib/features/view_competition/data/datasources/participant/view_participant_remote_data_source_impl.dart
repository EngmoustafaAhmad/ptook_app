import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/shared/data/models/participant_model.dart';
import 'package:ptook/features/view_competition/data/datasources/participant/i_view_participant_remote_data_source.dart';

class ViewParticipantRemoteDataSourceImpl
    implements IViewParticipantRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ViewParticipantRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  DocumentReference<Map<String, dynamic>> _userDocRef(String userId) =>
      firestore.collection('users').doc(userId);

  @override
  Future<void> joinIndividualCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be authenticated to join.');
    }

    try {
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef =
          compDocRef.collection('participants').doc(user.uid);
      final userDocRef = _userDocRef(user.uid);

      await firestore.runTransaction((transaction) async {
        final compSnapshot = await transaction.get(compDocRef);
        if (!compSnapshot.exists) {
          throw const ServerException('Target competition does not exist.');
        }

        final participantModel = ParticipantModel(
          id: user.uid,
          userId: user.uid,
          competitionId: competitionId,
          name: user.displayName ?? 'Anonymous Participant',
          avatarUrl: user.photoURL ?? '',
          points: 0,
          role: 'participant',
          joinedAt: DateTime.now(),
        );

        // 1. Write participant subcollection entry
        transaction.set(participantDocRef, participantModel.toJson());

        // 2. Update competition aggregate fields
        transaction.update(compDocRef, {
          'participantIds': FieldValue.arrayUnion([user.uid]),
          'participantsCount': FieldValue.increment(1),
        });

        // 3. Increment user's joined competitions count
        transaction.update(userDocRef, {
          'joinedCompetitionsCount': FieldValue.increment(1),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to join competition.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveIndividualCompetition(String competitionId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const ServerException('User must be authenticated to leave.');
    }

    try {
      final compDocRef = _competitionsRef.doc(competitionId);
      final participantDocRef =
          compDocRef.collection('participants').doc(user.uid);
      final userDocRef = _userDocRef(user.uid);

      await firestore.runTransaction((transaction) async {
        final compSnapshot = await transaction.get(compDocRef);
        if (!compSnapshot.exists) {
          throw const ServerException('Target competition does not exist.');
        }

        // 1. Remove participant subcollection record
        transaction.delete(participantDocRef);

        // 2. Decrement competition counters and array list
        transaction.update(compDocRef, {
          'participantIds': FieldValue.arrayRemove([user.uid]),
          'participantsCount': FieldValue.increment(-1),
        });

        // 3. Decrement user's joined competitions count
        transaction.update(userDocRef, {
          'joinedCompetitionsCount': FieldValue.increment(-1),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to leave competition.');
    } catch (e) {
      throw ServerException(e.toString());
    }
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
      throw ServerException(e.message ?? 'Failed to fetch participants.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ParticipantModel>> streamParticipants(String competitionId) {
    return _competitionsRef
        .doc(competitionId)
        .collection('participants')
        .snapshots()
        .map((snapshot) {
      final participants = snapshot.docs
          .map((doc) => ParticipantModel.fromJson(doc.data(), doc.id))
          .toList();

      participants.sort((a, b) => b.points.compareTo(a.points));
      return participants;
    });
  }
}