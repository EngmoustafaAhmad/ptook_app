import 'package:ptook/features/shared/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.handle,
    super.bio,
    super.avatarUrl,
    super.totalPower,
    super.joinedCompetitionsCount,
    super.savedCompetitionsCount,
    super.savedCompetitionIds,
    required super.createdAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      handle: entity.handle,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      totalPower: entity.totalPower,
      joinedCompetitionsCount: entity.joinedCompetitionsCount,
      savedCompetitionsCount: entity.savedCompetitionsCount,
      savedCompetitionIds: entity.savedCompetitionIds,
      createdAt: entity.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final rawName = json['name']?.toString() ?? '';
    final defaultHandle = '@${(rawName.isEmpty ? 'user' : rawName).replaceAll(' ', '_').toLowerCase()}';

    return UserModel(
      id: id ?? json['id']?.toString() ?? json['uid']?.toString() ?? '',
      name: rawName,
      email: json['email']?.toString() ?? '',
      handle: json['handle']?.toString() ?? defaultHandle,
      bio: json['bio']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      totalPower: (json['totalPower'] as num?)?.toInt() ?? 3,
      joinedCompetitionsCount: (json['joinedCompetitionsCount'] as num?)?.toInt() ?? 0,
      savedCompetitionsCount: (json['savedCompetitionsCount'] as num?)?.toInt() ?? 0,
      savedCompetitionIds: json['savedCompetitionIds'] != null
          ? Set<String>.from(json['savedCompetitionIds'] as Iterable)
          : const {},
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'handle': handle,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'totalPower': totalPower,
      'joinedCompetitionsCount': joinedCompetitionsCount,
      'savedCompetitionsCount': savedCompetitionsCount,
      'savedCompetitionIds': savedCompetitionIds.toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserEntity toEntity() => this; // Since UserModel inherits from UserEntity, explicit instantiation is redundant

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    
    try {
      // Handles Cloud Firestore Timestamp objects
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }
}