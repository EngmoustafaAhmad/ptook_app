import 'package:dartz/dartz.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  /// Executes registration flow yielding Either an error message or the authenticated UserEntity.
  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}