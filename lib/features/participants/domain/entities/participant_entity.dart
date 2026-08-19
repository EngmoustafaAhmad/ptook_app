import 'package:equatable/equatable.dart';
import 'podium_tier.dart';

/// Represents a participant within a competition in the domain layer.
class ParticipantEntity extends Equatable {
  final String id; // 🌟 Unique identifier (e.g., Firestore Document ID)
  final String userId;
  final String competitionId;
  final String name; // 🌟 Display name for leaderboards & lists
  final String? avatarUrl; // 🌟 Profile image URL
  final String role; // e.g., 'member', 'leader', 'admin'
  final String? teamId;
  final int points;
  final DateTime joinedAt;

  // 🌟 Stars & Leaderboard Properties
  final PodiumTier podiumTier;
  final int totalStarsEarned; // Total accumulated stars across ALL competitions

  const ParticipantEntity({
    required this.id,
    required this.userId,
    required this.competitionId,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.teamId,
    required this.points,
    required this.joinedAt,
    this.podiumTier = PodiumTier.none,
    this.totalStarsEarned = 0,
  });

  // ===========================================================================
  // 💡 SERIALIZATION
  // ===========================================================================

  /// Converts the entity instance into a JSON/Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'competitionId': competitionId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'teamId': teamId,
      'points': points,
      'joinedAt': joinedAt.toIso8601String(),
      'podiumTier': podiumTier.name,
      'totalStarsEarned': totalStarsEarned,
    };
  }

  // ===========================================================================
  // 💡 DOMAIN CONVENIENCE GETTERS
  // ===========================================================================

  /// Reads current competition stars easily based on podium tier
  int get currentCompetitionStars => podiumTier.stars;

  /// Generates user initials for UI avatar fallbacks (e.g., "John Doe" -> "JD")
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Domain Role Checks
  bool get isLeader => role.toLowerCase() == 'leader';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isMember => role.toLowerCase() == 'member';

  /// True if participant currently occupies a podium position (Gold, Silver, Bronze)
  bool get isOnPodium => podiumTier != PodiumTier.none;

  // ===========================================================================
  // 🔄 IMMUTABLE STATE UPDATES
  // ===========================================================================

  /// Immutable copyWith method for state updates
  ParticipantEntity copyWith({
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
    return ParticipantEntity(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        competitionId,
        name,
        avatarUrl,
        role,
        teamId,
        points,
        joinedAt,
        podiumTier,
        totalStarsEarned,
      ];
}