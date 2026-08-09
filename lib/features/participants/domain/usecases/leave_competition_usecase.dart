import '../repositories/i_participant_repository.dart';

class LeaveCompetitionUseCase {
  final IParticipantRepository repository;

  LeaveCompetitionUseCase(this.repository);

  Future<void> call({
    required String competitionId,
    required String userId,
  }) {
    return repository.leaveCompetition(
      competitionId: competitionId,
      userId: userId,
    );
  }
}