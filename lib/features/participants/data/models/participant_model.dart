import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/entities/podium_tier.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.id, // 👈 Bound directly to ParticipantEntity.id
    required super.userId,
    required super.competitionId,
    required super.name,
    super.avatarUrl,
    required super.role,
    super.teamId,
    required super.points,
    required super.joinedAt,
    super.podiumTier = PodiumTier.none,
    super.totalStarsEarned = 0,
  });

  /// Factory to parse Firestore documents / JSON maps safely
  factory ParticipantModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Handle Firestore Timestamp or ISO DateTime string
    DateTime parsedJoinedAt;
    if (json['joinedAt'] is Timestamp) {
      parsedJoinedAt = (json['joinedAt'] as Timestamp).toDate();
    } else if (json['joinedAt'] is String) {
      parsedJoinedAt = DateTime.parse(json['joinedAt']);
    } else {
      parsedJoinedAt = DateTime.now();
    }

    // Safely parse PodiumTier (supports string name or integer rank fallback)
    final int rank = json['rank'] ?? 0;
    final podiumTier = json['podiumTier'] != null
        ? PodiumTier.values.firstWhere(
            (e) => e.name == json['podiumTier'],
            orElse: () => PodiumTier.fromRank(rank),
          )
        : PodiumTier.fromRank(rank);

    return ParticipantModel(
      // 💡 Fallback order: docId argument -> json['id'] -> json['userId'] -> empty string
      id: docId ?? json['id'] ?? json['userId'] ?? '',
      userId: json['userId'] ?? '',
      competitionId: json['competitionId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] ?? 'member',
      teamId: json['teamId'] as String?,
      points: json['points'] ?? 0,
      joinedAt: parsedJoinedAt,
      podiumTier: podiumTier,
      totalStarsEarned: json['totalStarsEarned'] ?? 0,
    );
  }

  /// Converts the model back to Firestore map format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'competitionId': competitionId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'teamId': teamId,
      'points': points,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'rank': podiumTier.rank,
      'podiumTier': podiumTier.name,
      'totalStarsEarned': totalStarsEarned,
    };
  }

  /// Convenience method specifically for initial document creation in Firestore
  Map<String, dynamic> toCreateJson() {
    final map = toJson();
    map['joinedAt'] = FieldValue.serverTimestamp();
    return map;
  }

  /// Helper to convert a domain entity into a data model
  factory ParticipantModel.fromEntity(ParticipantEntity entity) {
    return ParticipantModel(
      id: entity.id, // 👈 Passes entity ID correctly
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

  /// Copy with helper method
  ParticipantModel copyWith({
    String? id,
    String? userId,
    String? competitionId,
    String? name,
    String? avatarUrl,
    String? role,
    String? teamId,
    int? points,
    DateTime? joinedAt,
    PodiumTier? podiumTier,
    int? totalStarsEarned,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      competitionId: competitionId ?? this.competitionId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      points: points ?? this.points,
      joinedAt: joinedAt ?? this.joinedAt,
      podiumTier: podiumTier ?? this.podiumTier,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
    );
  }
}