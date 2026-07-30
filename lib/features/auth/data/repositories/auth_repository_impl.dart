import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 استيراد مهم لاصطياد استثناءات Firebase
import 'package:flutter/foundation.dart';
import 'package:ptook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ptook/features/auth/domain/entities/user_entity.dart';
import 'package:ptook/features/auth/domain/repositories/i_auth_repository.dart';

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
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      // 💡 تصفية أخطاء إنشاء الحساب لرفع جودة الـ UX
      return Left(_getCleanAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      // 🛠️ تم إصلاح التداخل هنا؛ هذا البلوك سيقبض على أي كراش صامت في الموديل أو الداتابيز ويطبعه فوراً
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
      // 💡 استدعاء دالة الـ login المحدثة من الـ RemoteDataSource
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel); // يعيد الـ UserModel محمل بالبيانات والـ points بنجاح
    } on FirebaseAuthException catch (e) {
      // 💡 تصفية أخطاء تسجيل الدخول لرفع جودة الـ UX
      return Left(_getCleanAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      // 🛠️ إضافة الطباعة هنا أيضاً لأنها المكان الذي يعلق فيه التطبيق عند الدخول ببيانات صحيحة!
      if (kDebugMode) {
        print("🚨 REPOSITORY LOGIN CRASH: $e");
        print("📋 STACKTRACE: $stackTrace");
      }
      return Left(e.toString());
    }
  }

  // 🛠️ دالة مركزية موحدة لتحويل الـ Firebase Codes إلى رسائل بشرية مفهومة وأنيقة
  String _getCleanAuthErrorMessage(String code) {
    switch (code) {
      // أخطاء الـ Register
      case 'email-already-in-use':
        return 'This email address is already registered. Try logging in.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger one.';
        
      // أخطاء الـ Login
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // فيربيز تجمع أخطاء تسجيل الدخول هنا أحياناً لأسباب أمنية
        return 'Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return 'This user account has been disabled or suspended.';
        
      // أخطاء عامة ومشتركة
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
        
      default:
        return 'An unexpected authentication error occurred. Please try again.';
    }
  }
}