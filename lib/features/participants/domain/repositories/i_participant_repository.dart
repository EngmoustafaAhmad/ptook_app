import '../entities/participant_entity.dart';

abstract class IParticipantRepository {
  /// Allows a user to join a specific competition.
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  });

  /// Allows a user to leave a competition.
  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  });

  /// Fetches all participants for a competition (ordered for leaderboard).
  Future<List<ParticipantEntity>> getCompetitionParticipants(
    String competitionId,
  );

  /// Updates participant points (e.g. adding 50 points or deducting 10).
  Future<void> updatePoints({
    required String competitionId,
    required String userId,
    required int points,
  });

  /// Awards podium tier stars (Gold, Silver, Bronze) when a competition ends.
  Future<void> assignPodiumStars({
    required String competitionId,
    required String userId,
    required int rank, // 1 for Gold (3 stars), 2 for Silver (1 star), 3 for Bronze (2 stars)
  });
}