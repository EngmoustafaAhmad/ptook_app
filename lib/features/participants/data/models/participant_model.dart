import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/entities/podium_tier.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.userId,
    required super.competitionId,
    required super.role,
    super.teamId,
    required super.points,
    required super.joinedAt,
    super.podiumTier = PodiumTier.none,
    super.totalStarsEarned = 0,
  });

  /// Factory to parse Firestore documents / JSON maps safely
  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp or ISO DateTime string
    DateTime parsedJoinedAt;
    if (json['joinedAt'] is Timestamp) {
      parsedJoinedAt = (json['joinedAt'] as Timestamp).toDate();
    } else if (json['joinedAt'] is String) {
      parsedJoinedAt = DateTime.parse(json['joinedAt']);
    } else {
      parsedJoinedAt = DateTime.now();
    }

    // Determine PodiumTier from rank if available
    final int rank = json['rank'] ?? 0;
    final podiumTier = PodiumTier.fromRank(rank);

    return ParticipantModel(
      userId: json['userId'] ?? '',
      competitionId: json['competitionId'] ?? '',
      role: json['role'] ?? 'member',
      teamId: json['teamId'],
      points: json['points'] ?? 0,
      joinedAt: parsedJoinedAt,
      podiumTier: podiumTier,
      totalStarsEarned: json['totalStarsEarned'] ?? 0,
    );
  }

  /// Converts the model back to Firestore map format
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'competitionId': competitionId,
      'role': role,
      'teamId': teamId,
      'points': points,
      'joinedAt': FieldValue.serverTimestamp(), // Firestore server-side timestamp
      'rank': podiumTier.rank,
      'totalStarsEarned': totalStarsEarned,
    };
  }

  /// Helper to convert a domain entity into a data model
  factory ParticipantModel.fromEntity(ParticipantEntity entity) {
    return ParticipantModel(
      userId: entity.userId,
      competitionId: entity.competitionId,
      role: entity.role,
      teamId: entity.teamId,
      points: entity.points,
      joinedAt: entity.joinedAt,
      podiumTier: entity.podiumTier,
      totalStarsEarned: entity.totalStarsEarned,
    );
  }
}