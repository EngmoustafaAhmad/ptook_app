import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class UpdateCompetitoinParticipantPointsUseCase {
  final IManageCompetitionRepository repository;

  UpdateCompetitoinParticipantPointsUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    return await repository.updateCompetitoinParticipantPoints(
      competitionId: competitionId,
      participantId: participantId,
      addedPoints: addedPoints,
    );
  }
}
