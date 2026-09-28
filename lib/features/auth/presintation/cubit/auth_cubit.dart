import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/auth/domain/usecases/login_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/register_usecase.dart';
import 'package:ptook/features/auth/domain/usecases/send_password_reset_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;

  AuthCubit({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.sendPasswordResetUseCase,
  }) : super(AuthInitial());

  // 1️⃣ User Registration Flow
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());

    final result = await registerUseCase.call(
      email: email,
      password: password,
      name: name,
    );

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

  // 2️⃣ User Login Flow
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUseCase.call(
      email: email,
      password: password,
    );

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

  // 3️⃣ Password Reset Flow
  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());

    final result = await sendPasswordResetUseCase.call(email: email);

    result.fold(
      (failureMessage) {
        final cleanMessage = _getLocalizedErrorMessage(failureMessage);
        emit(AuthError(cleanMessage));
      },
      (_) {
        // Emits success using a sentinel/null state if AuthSuccess expects a UserEntity
        emit(const AuthPasswordResetSuccess('Password reset link sent! Check your inbox.'));
      },
    );
  }

  // 🛠️ Cleans raw Firebase exception tags from UI display strings
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
      return 'Invalid email or password. Please check your credentials.';
    } else if (rawMessage.contains('user-disabled')) {
      return 'This user account has been disabled or suspended.';
    }

    return rawMessage.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}