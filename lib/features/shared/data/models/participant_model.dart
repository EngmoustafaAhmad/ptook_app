import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptook/features/shared/domain/entities/podium_tier.dart';
import '../../domain/entities/participant_entity.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.id,
    required super.userId,
    required super.competitionId,
    required super.name,
    super.avatarUrl,
    required super.role,
    super.teamId,
    required super.points,
    required super.joinedAt,
    super.podiumTier,
    super.totalStarsEarned,
  });

    factory ParticipantModel.fromJson(Map<String, dynamic> json, String docId) {
    return ParticipantModel(
      id: docId,
      // Fallback to docId if userId isn't stored as a field in older Firestore documents
      userId: (json['userId'] as String?)?.isNotEmpty == true
          ? json['userId']!
          : docId,
      competitionId: json['competitionId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'member',
      teamId: json['teamId'],
      points: (json['totalPoints'] as num?)?.toInt() ??
              (json['points'] as num?)?.toInt() ?? 0,
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
      'userId': userId,
      'competitionId': competitionId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'teamId': teamId,
      // Persist both keys so both team and participant streams stay aligned
      'points': points,
      'totalPoints': points,
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
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      teamId: entity.teamId,
      points: entity.points,
      joinedAt: entity.joinedAt,
      podiumTier: entity.podiumTier,
      totalStarsEarned: entity.totalStarsEarned,
    );
  }
}