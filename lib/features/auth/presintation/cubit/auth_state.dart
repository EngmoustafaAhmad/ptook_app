import 'package:equatable/equatable.dart';
import 'package:ptook/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// الحالة الابتدائية
class AuthInitial extends AuthState {}

// حالة التحميل (إظهار Spinner)
class AuthLoading extends AuthState {}

// حالة النجاح
class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// حالة الخطأ
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}