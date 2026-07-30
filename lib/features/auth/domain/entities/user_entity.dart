import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final int points;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.points = 0,
  });

  @override
  List<Object?> get props => [uid, email, name, points];
}