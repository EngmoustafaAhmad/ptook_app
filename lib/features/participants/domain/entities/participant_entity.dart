import 'package:equatable/equatable.dart';
import 'podium_tier.dart';

class ParticipantEntity extends Equatable {
  final String userId;
  final String competitionId;
  final String role; // e.g., 'member', 'leader', 'admin'
  final String? teamId;
  final int points;
  final DateTime joinedAt;
  
  // 🌟 Stars & Leaderboard Properties
  final PodiumTier podiumTier;
  final int totalStarsEarned; // Total accumulated stars across ALL competitions

  const ParticipantEntity({
    required this.userId,
    required this.competitionId,
    required this.role,
    this.teamId,
    required this.points,
    required this.joinedAt,
    this.podiumTier = PodiumTier.none,
    this.totalStarsEarned = 0,
  });

  /// Convenience getter to read current competition stars easily
  int get currentCompetitionStars => podiumTier.stars;

  /// Senior practice: Immutable copyWith method for state updates
  ParticipantEntity copyWith({
    String? userId,
    String? competitionId,
    String? role,
    String? teamId,
    int? points,
    DateTime? joinedAt,
    PodiumTier? podiumTier,
    int? totalStarsEarned,
  }) {
    return ParticipantEntity(
      userId: userId ?? this.userId,
      competitionId: competitionId ?? this.competitionId,
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
        userId,
        competitionId,
        role,
        teamId,
        points,
        joinedAt,
        podiumTier,
        totalStarsEarned,
      ];
}