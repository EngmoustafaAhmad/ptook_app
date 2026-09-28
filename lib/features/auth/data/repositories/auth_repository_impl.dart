import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      // UserModel extends UserEntity, so it implicitly satisfies Right(UserEntity)
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_getCleanAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🚨 REPOSITORY REGISTER CRASH: $e");
        print("📋 STACKTRACE: $stackTrace");
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_getCleanAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🚨 REPOSITORY LOGIN CRASH: $e");
        print("📋 STACKTRACE: $stackTrace");
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_getCleanAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🚨 REPOSITORY PASSWORD RESET CRASH: $e");
        print("📋 STACKTRACE: $stackTrace");
      }
      return Left(e.toString());
    }
  }

  String _getCleanAuthErrorMessage(String code) {
    switch (code) {
      // Register Errors
      case 'email-already-in-use':
        return 'This email address is already registered. Try logging in.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger one.';

      // Login / Auth Errors
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return 'This user account has been disabled or suspended.';

      // Shared Network / Input Errors
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return 'An unexpected authentication error occurred. Please try again.';
    }
  }
}