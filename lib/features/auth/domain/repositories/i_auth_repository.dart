import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class IAuthRepository {
  // 1. منطق تسجيل حساب جديد
  Future<Either<String, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  // 💡 2. الدالة الجديدة لتسجيل الدخول
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  });
}