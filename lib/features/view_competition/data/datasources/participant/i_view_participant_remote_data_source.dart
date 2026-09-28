import 'package:ptook/features/shared/data/models/participant_model.dart';

abstract class IViewParticipantRemoteDataSource {

  // Participant Queries
  Future<List<ParticipantModel>> getParticipants(String competitionId);

  // Participant Competition Actions (Modifies competition.participantsCount)
  Future<void> joinIndividualCompetition(String competitionId);

  Future<void> leaveIndividualCompetition(String competitionId);

  Stream<List<ParticipantModel>> streamParticipants(String competitionId);

}