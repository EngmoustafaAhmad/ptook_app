import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/core/errors/exceptions.dart';
import 'package:ptook/features/Manage%20Competitions/data/datasources/participants/i_manage_participant_remote_data_source.dart';
import 'package:ptook/features/shared/data/models/participant_model.dart';

class ManageParticipantRemoteDataSourceImpl
    implements IManageParticipantRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ManageParticipantRemoteDataSourceImpl({
    required this.firestore,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _competitionsRef =>
      firestore.collection('competitions');

  @override
  Future<void> updateCompetitionParticipantPoints({
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
}