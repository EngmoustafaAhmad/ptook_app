import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';

class UpdateTeamParticipantPointsUseCase {
  final IManageCompetitionRepository _repository;

  UpdateTeamParticipantPointsUseCase(this._repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  }) async {
    return await _repository.updateTeamParticipantPoints(
      competitionId: competitionId,
      teamId: teamId,
      participantId: participantId,
      addedPoints: addedPoints,
    );
  }
}