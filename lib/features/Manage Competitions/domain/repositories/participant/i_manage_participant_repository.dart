import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

abstract class IManageParticipantRepository {
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  Future<Result<void>> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  Future<Result<void>> updateCompetitionParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });
}