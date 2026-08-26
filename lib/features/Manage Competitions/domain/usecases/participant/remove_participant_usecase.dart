import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class RemoveParticipantUseCase {
  final IManageCompetitionRepository repository;

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