import 'package:dartz/dartz.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';

class SendPasswordResetUseCase {
  final IAuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<Either<String, void>> call({required String email}) async {
    return await repository.sendPasswordResetEmail(email: email);
  }
}