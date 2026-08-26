import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class UpdateParticipantPointsUseCase {
  final IManageCompetitionRepository repository;

  UpdateParticipantPointsUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  }) async {
    return await repository.updateParticipantPoints(
      competitionId: competitionId,
      participantId: participantId,
      addedPoints: addedPoints,
    );
  }
}