import 'package:ptook/features/shared/data/models/participant_model.dart';

abstract class IManageParticipantRemoteDataSource {
  Future<void> updateCompetitionParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });

  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  Stream<List<ParticipantModel>> streamParticipants(String competitionId);
}