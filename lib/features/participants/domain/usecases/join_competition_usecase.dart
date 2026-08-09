import 'package:ptook/features/participants/domain/repositories/i_participant_repository.dart';

class JoinCompetitionUseCase {
  final IParticipantRepository repository;

  // 🎯 Positional constructor (consistent with your other Use Cases)
  JoinCompetitionUseCase(this.repository);

  Future<void> call({
    required String competitionId,
    required String userId,
    String role = 'member',
    String? teamId,
  }) async {
    await repository.joinCompetition(
      competitionId: competitionId,
      userId: userId,
      role: role,
      teamId: teamId,
    );
  }
}