import 'package:ptook/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.points,
  });

  // تحويل الكائن إلى Map لحفظه في Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'points': points,
    };
  }

  // 💡 إضافة الـ fromJson ليتوافق تماماً مع كود الـ RemoteDataSource القديم
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  // دالة الـ fromMap الحالية الخاصة بك (ممتازة لاستقبال بيانات الـ Realtime Database العادية)
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}