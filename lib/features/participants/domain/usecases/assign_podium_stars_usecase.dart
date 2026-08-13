import '../repositories/i_participant_repository.dart';

/// UseCase responsible for assigning podium ranks and awarding lifetime stars to participants.
class AssignPodiumStarsUseCase {
  final IParticipantRepository repository;

  AssignPodiumStarsUseCase(this.repository);

  Future<void> call({
    required String competitionId,
    required String userId,
    required int rank,
  }) async {
    return await repository.assignPodiumStars(
      competitionId: competitionId,
      userId: userId,
      rank: rank,
    );
  }
}