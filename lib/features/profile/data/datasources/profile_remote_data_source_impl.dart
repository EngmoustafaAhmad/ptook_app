import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/profile/data/datasources/i_profile_remote_data_source.dart';
import 'package:ptook/features/shared/data/models/user_model.dart';

class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  Stream<UserModel> streamUserProfile(String userId) {
    return _usersRef.doc(userId).snapshots().asyncMap((snapshot) async {
      // 1. If document doesn't exist in Firestore, lazily seed a default profile
      if (!snapshot.exists || snapshot.data() == null) {
        final initialUser = UserModel(
          id: userId,
          name: 'User_${userId.substring(0, 5)}',
          email: '',
          handle: '@user_${userId.substring(0, 5)}',
          totalPower: 0, // Fallback set to 0 (Auth register sets the initial 3)
          joinedCompetitionsCount: 0,
          savedCompetitionsCount: 0,
          createdAt: DateTime.now(),
        );

        // Save to Firestore (fires snapshot update automatically)
        await updateUserProfile(initialUser);
        return initialUser;
      }

      // 2. Return valid user model
      return UserModel.fromJson(snapshot.data()!, id: snapshot.id);
    });
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      final initialUser = UserModel(
        id: userId,
        name: 'User_${userId.substring(0, 5)}',
        email: '',
        handle: '@user_${userId.substring(0, 5)}',
        totalPower: 0,
        joinedCompetitionsCount: 0,
        savedCompetitionsCount: 0,
        createdAt: DateTime.now(),
      );

      await updateUserProfile(initialUser);
      return initialUser;
    }

    return UserModel.fromJson(doc.data()!, id: doc.id);
  }

  @override
  Future<void> updateUserProfile(UserModel userModel) async {
    // 1. Update primary User profile document
    final userDocRef = _usersRef.doc(userModel.id);
    await userDocRef.set(userModel.toJson(), SetOptions(merge: true));

    // 2. Query all active participant documents by userId
    final participantDocs = await _firestore
        .collectionGroup('participants')
        .where('userId', isEqualTo: userModel.id)
        .get();

    if (participantDocs.docs.isEmpty) return;

    // 3. Batch updates in chunks of 450 to stay under Firestore's 500 ops limit
    const int batchSize = 450;
    final docs = participantDocs.docs;

    for (var i = 0; i < docs.length; i += batchSize) {
      final batch = _firestore.batch();
      final end = (i + batchSize < docs.length) ? i + batchSize : docs.length;

      for (var j = i; j < end; j++) {
        batch.update(docs[j].reference, {
          'name': userModel.name,
          'bio': userModel.bio ?? '',
          'avatarUrl': userModel.avatarUrl ?? '',
          'totalPower': userModel.totalPower,
          'power': userModel.totalPower, // Backward compatibility
          'userId': userModel.id,
        });
      }

      await batch.commit();
    }
  }
  
}