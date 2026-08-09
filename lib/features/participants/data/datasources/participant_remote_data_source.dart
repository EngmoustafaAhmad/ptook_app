import '../models/participant_model.dart';

abstract class IParticipantRemoteDataSource {
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  });

  Future<void> leaveCompetition({
    required String competitionId,
    required String userId,
  });

  Future<List<ParticipantModel>> getCompetitionParticipants(
    String competitionId,
  );

  Future<void> updatePoints({
    required String competitionId,
    required String userId,
    required int points,
  });

  Future<void> assignPodiumStars({
    required String competitionId,
    required String userId,
    required int rank,
  });
}