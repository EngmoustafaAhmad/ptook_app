import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

abstract class IViewParticipantRepository {

    Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  );

  // Competition Participant Actions (Modifies competition.participantsCount)
  Future<Result<void>> joinIndividualCompetition(String competitionId);

  Future<Result<void>> leaveIndividualCompetition(String competitionId);

  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

}