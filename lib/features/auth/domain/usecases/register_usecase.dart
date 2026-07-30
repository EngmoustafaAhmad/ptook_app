import 'package:dartz/dartz.dart';
import 'package:ptook/features/auth/domain/entities/user_entity.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  // 💡 التعديل هنا: حذف المعامل الإضافي الذي كان يسبب إجبارية تمرير الـ null
  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.register(email: email, password: password, name: name);
  }
}