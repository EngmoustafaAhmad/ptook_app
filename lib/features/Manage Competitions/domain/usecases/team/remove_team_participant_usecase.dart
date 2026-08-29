import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';

class RemoveTeamParticipantUseCase {
  final IManageCompetitionRepository _repository;

  RemoveTeamParticipantUseCase(this._repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
    required String participantId,
  }) async {
    return await _repository.removeTeamParticipant(
      competitionId: competitionId,
      teamId: teamId,
      participantId: participantId,
    );
  }
}