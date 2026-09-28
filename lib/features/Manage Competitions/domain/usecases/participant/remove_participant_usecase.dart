import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/participant/i_manage_participant_repository.dart';

class RemoveParticipantUseCase {
  final IManageParticipantRepository repository;

  RemoveParticipantUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String participantId,
  }) async {
    return await repository.removeParticipant(
      competitionId: competitionId,
      participantId: participantId,
    );
  }
}