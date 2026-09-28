import 'package:equatable/equatable.dart';
import 'package:ptook/features/shared/domain/entities/podium_tier.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

class ParticipantEntity extends Equatable {
  final String id;
  final String userId;
  final String competitionId;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String role; // e.g., 'member', 'leader', 'admin'
  final String? teamId;
  final int points;
  final int totalPower; // ⚡ Power state synced with UserEntity
  final DateTime joinedAt;

  // Stars & Leaderboard Properties
  final PodiumTier podiumTier;
  final int totalStarsEarned;

  const ParticipantEntity({
    required this.id,
    required this.userId,
    required this.competitionId,
    required this.name,
    this.bio,
    this.avatarUrl,
    required this.role,
    this.teamId,
    required this.points,
    this.totalPower = 0,
    required this.joinedAt,
    this.podiumTier = PodiumTier.none,
    this.totalStarsEarned = 0,
  });

  /// Factory to sync user attributes and totalPower when joining a competition
  factory ParticipantEntity.fromUser({
    required String participantId,
    required UserEntity user,
    required String competitionId,
    required String role,
    int initialPoints = 0,
    String? teamId,
    PodiumTier podiumTier = PodiumTier.none,
    int totalStarsEarned = 0,
  }) {
    return ParticipantEntity(
      id: participantId,
      userId: user.id,
      competitionId: competitionId,
      name: user.name,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      role: role,
      teamId: teamId,
      points: initialPoints,
      totalPower: user.totalPower, // ⚡ Inherits power from user model
      joinedAt: DateTime.now(),
      podiumTier: podiumTier,
      totalStarsEarned: totalStarsEarned,
    );
  }

  int get currentCompetitionStars => podiumTier.stars;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isLeader => role.toLowerCase() == 'leader';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isMember => role.toLowerCase() == 'member';
  bool get isOnPodium => podiumTier != PodiumTier.none;

  ParticipantEntity copyWith({
    String? id,
    String? userId,
    String? competitionId,
    String? name,
    String? bio,
    String? avatarUrl,
    String? role,
    String? teamId,
    int? points,
    int? totalPower,
    DateTime? joinedAt,
    PodiumTier? podiumTier,
    int? totalStarsEarned,
  }) {
    return ParticipantEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      competitionId: competitionId ?? this.competitionId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      points: points ?? this.points,
      totalPower: totalPower ?? this.totalPower,
      joinedAt: joinedAt ?? this.joinedAt,
      podiumTier: podiumTier ?? this.podiumTier,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        competitionId,
        name,
        bio,
        avatarUrl,
        role,
        teamId,
        points,
        totalPower,
        joinedAt,
        podiumTier,
        totalStarsEarned,
      ];
}