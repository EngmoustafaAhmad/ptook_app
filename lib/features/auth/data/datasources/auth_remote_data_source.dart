import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/features/shared/data/models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // Update Firebase Auth display name locally
    await credential.user?.updateDisplayName(name);

    // Generate unique handle format (e.g., "Ahmed Hassan" -> "@ahmed_hassan_a1b2")
    final cleanName = name.trim().replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    final uniqueSuffix = uid.substring(0, 4);
    final formattedHandle = '@${cleanName}_$uniqueSuffix';

    final userModel = UserModel(
      id: uid,
      email: email,
      name: name,
      handle: formattedHandle,
      totalPower: 3, // Initial sign-up power allocation ⚡
      joinedCompetitionsCount: 0,
      savedCompetitionsCount: 0,
      createdAt: DateTime.now(),
    );

    // Save complete schema to Firestore
    await firestore
        .collection('users')
        .doc(uid)
        .set(userModel.toJson());

    return userModel;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromJson(
        snapshot.data()!,
        id: uid,
      );
    }

    // Fallback if user exists in FirebaseAuth but document is missing in Firestore
    final fallbackName = credential.user!.displayName ?? "User";
    final cleanName = fallbackName.trim().replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    final fallbackUser = UserModel(
      id: uid,
      email: email,
      name: fallbackName,
      handle: '@${cleanName}_${uid.substring(0, 4)}',
      totalPower: 0, // Fallback set to 0 to avoid unintended power re-seeding
      joinedCompetitionsCount: 0,
      savedCompetitionsCount: 0,
      createdAt: DateTime.now(),
    );

    // Lazy seed document
    await firestore.collection('users').doc(uid).set(fallbackUser.toJson());

    return fallbackUser;
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await auth.sendPasswordResetEmail(email: email.trim());
  }
}