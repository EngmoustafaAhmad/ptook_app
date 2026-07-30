import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart'; // 💡 استيراد الـ UseCase الجديد لـ Login
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase; // 💡 إضافة المتغير هنا

  // تحديث الـ Constructor لاستقبال كلاهما
  AuthCubit({
    required this.registerUseCase,
    required this.loginUseCase,
  }) : super(AuthInitial());

  // 1️⃣ دالة إنشاء حساب جديد
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    // تغيير الحالة إلى تحميل
    emit(AuthLoading());

    // استدعاء UseCase
    final result = await registerUseCase.call(
      email: email,
      password: password,
      name: name,
    );

    // معالجة النتيجة القادمة من Repository (Either)
    result.fold(
      (failureMessage) {
        final cleanMessage = _getLocalizedErrorMessage(failureMessage);
        emit(AuthError(cleanMessage));
      },
      (userEntity) {
        emit(AuthSuccess(userEntity));
      },
    );
  }

  // 2️⃣ 💡 الدالة الجديدة لتسجيل الدخول
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    // تغيير الحالة إلى تحميل
    emit(AuthLoading());

    // استدعاء الـ UseCase الخاص بـ Login
    final result = await loginUseCase.call(
      email: email,
      password: password,
    );

    // معالجة النتيجة
    result.fold(
      (failureMessage) {
        final cleanMessage = _getLocalizedErrorMessage(failureMessage);
        emit(AuthError(cleanMessage));
      },
      (userEntity) {
        emit(AuthSuccess(userEntity)); // يعيد نفس حالة النجاح لتوحيد منطق الواجهة (UI Consumer)
      },
    );
  }

  // 🛠️ دالة داخلية لمسح رموز الأخطاء البرمجية الخاصة بـ Firebase
  String _getLocalizedErrorMessage(String rawMessage) {
    if (rawMessage.contains('email-already-in-use')) {
      return 'This email address is already registered. Try logging in.';
    } else if (rawMessage.contains('invalid-email')) {
      return 'The email address is badly formatted.';
    } else if (rawMessage.contains('weak-password')) {
      return 'The password is too weak. Please choose a stronger one.';
    } else if (rawMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (rawMessage.contains('user-not-found') || 
               rawMessage.contains('wrong-password') || 
               rawMessage.contains('invalid-credential')) {
      // 💡 إضافة تصفية أخطاء تسجيل الدخول الشهيرة هنا
      return 'Invalid email or password. Please check your credentials.';
    } else if (rawMessage.contains('user-disabled')) {
      return 'This user account has been disabled or suspended.';
    }
    
    // إذا كان الخطأ غير معروف أو تمت تصفيته مسبقاً، نرسله كما هو ولكن بدون الأقواس [firebase_auth/...]
    return rawMessage.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}