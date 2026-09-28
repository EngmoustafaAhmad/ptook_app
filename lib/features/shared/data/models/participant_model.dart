import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/shared/domain/entities/podium_tier.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import '../../domain/entities/participant_entity.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.id,
    required super.userId,
    required super.competitionId,
    required super.name,
    super.bio,
    super.avatarUrl,
    required super.role,
    super.teamId,
    required super.points,
    super.totalPower = 0,
    required super.joinedAt,
    super.podiumTier,
    super.totalStarsEarned,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json, String docId) {
    final extractedUserId = json['userId'] as String?;
    
    return ParticipantModel(
      id: docId,
      userId: (extractedUserId != null && extractedUserId.isNotEmpty)
          ? extractedUserId
          : docId,
      competitionId: json['competitionId'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: json['role'] ?? 'member',
      teamId: json['teamId'],
      points: (json['totalPoints'] as num?)?.toInt() ??
          (json['points'] as num?)?.toInt() ??
          0,
      totalPower: (json['totalPower'] as num?)?.toInt() ??
          (json['power'] as num?)?.toInt() ??
          0,
      joinedAt: (json['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      podiumTier: PodiumTier.values.firstWhere(
        (t) => t.name == json['podiumTier'],
        orElse: () => PodiumTier.none,
      ),
      totalStarsEarned: (json['totalStarsEarned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId.isNotEmpty ? userId : id,
      'competitionId': competitionId,
      'name': name,
      'bio': bio ?? '',
      'avatarUrl': avatarUrl ?? '',
      'role': role,
      'teamId': teamId,
      'points': points,
      'totalPoints': points,
      'totalPower': totalPower,
      'power': totalPower,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'podiumTier': podiumTier.name,
      'totalStarsEarned': totalStarsEarned,
    };
  }

  factory ParticipantModel.fromEntity(ParticipantEntity entity) {
    return ParticipantModel(
      id: entity.id,
      userId: entity.userId,
      competitionId: entity.competitionId,
      name: entity.name,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      teamId: entity.teamId,
      points: entity.points,
      totalPower: entity.totalPower,
      joinedAt: entity.joinedAt,
      podiumTier: entity.podiumTier,
      totalStarsEarned: entity.totalStarsEarned,
    );
  }

  /// 🔗 Bridge Factory: Directly maps UserEntity snapshot to a new ParticipantModel
  factory ParticipantModel.fromUser({
    required UserEntity user,
    required String competitionId,
    String role = 'member',
    String? teamId,
  }) {
    return ParticipantModel(
      id: user.id,
      userId: user.id,
      competitionId: competitionId,
      name: user.name,
      bio: user.bio ?? '',
      avatarUrl: user.avatarUrl ?? '',
      role: role,
      teamId: teamId,
      points: 0,
      totalPower: user.totalPower,
      joinedAt: DateTime.now(),
    );
  }
}