import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/participant/i_manage_participant_repository.dart';

class UpdateCompetitoinParticipantPointsUseCase {
  final IManageParticipantRepository repository;

  UpdateCompetitoinParticipantPointsUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    return await repository.updateCompetitionParticipantPoints(
      competitionId: competitionId,
      participantId: participantId,
      addedPoints: addedPoints,
    );
  }
}
