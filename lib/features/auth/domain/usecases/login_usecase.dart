// features/auth/domain/usecases/login_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:ptook/features/auth/domain/entities/user_entity.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  // 💡 التعديل الجوهري: حذف كل المعاملات الزائدة والـ null والـ Object
  // والاعتماد فقط على الـ Positional Parameter مثل الـ RegisterUseCase تماماً
  LoginUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}