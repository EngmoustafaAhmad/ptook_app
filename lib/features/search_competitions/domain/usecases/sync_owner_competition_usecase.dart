import 'package:cloud_firestore/cloud_firestore.dart';

class SyncOwnerCompetitionsUseCase {
  final FirebaseFirestore _firestore;

  // ✅ Clean constructor with optional named argument
  SyncOwnerCompetitionsUseCase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> call({
    required String ownerId,
    required String ownerName,
    String? ownerAvatarUrl,
  }) async {
    // Query all competitions created by this user
    final querySnapshot = await _firestore
        .collection('competitions')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    // Use a Firestore Batch write (up to 500 writes per batch)
    final batch = _firestore.batch();

    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'ownerName': ownerName,
        'ownerAvatarUrl': ownerAvatarUrl,
      });
    }

    await batch.commit();
  }
}