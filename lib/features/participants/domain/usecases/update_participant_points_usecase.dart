import '../repositories/i_participant_repository.dart';

class UpdatePointsUseCase {
  final IParticipantRepository repository;

  UpdatePointsUseCase(this.repository);

  Future<void> call({
    required String competitionId,
    required String userId,
    required int points,
  }) {
    return repository.updatePoints(
      competitionId: competitionId,
      userId: userId,
      points: points,
    );
  }
}