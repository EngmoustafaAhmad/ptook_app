import 'package:dartz/dartz.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  /// Registers a new user account with initial default values (e.g. totalPower = 3).
  Future<Either<String, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Authenticates an existing user and fetches their profile snapshot.
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Sends a password reset link to the user's registered email address.
  Future<Either<String, void>> sendPasswordResetEmail({
    required String email,
  });
}