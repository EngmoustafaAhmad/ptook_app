import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ptook/features/auth/data/models/user_model.dart';

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

  // 🌟 CRITICAL ADDITION: Update Firebase Auth Profile
  // This allows auth.currentUser.displayName to hold the name in local memory!
  await credential.user?.updateDisplayName(name);

  final userModel = UserModel(
    uid: credential.user!.uid,
    email: email,
    name: name,
    points: 0,
  );

  await firestore
      .collection('users')
      .doc(userModel.uid)
      .set(
        userModel.toJson(),
      );

  return userModel;
}


  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {

    final credential =
        await auth.signInWithEmailAndPassword(
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
      );

    }


    return UserModel(
      uid: uid,
      email: email,
      name: credential.user!.displayName ?? "User",
      points: 0,
    );
  }
}