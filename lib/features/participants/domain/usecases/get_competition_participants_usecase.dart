import '../entities/participant_entity.dart';
import '../repositories/i_participant_repository.dart';

class GetCompetitionParticipantsUseCase {
  final IParticipantRepository repository;

  GetCompetitionParticipantsUseCase(this.repository);

  Future<List<ParticipantEntity>> call(String competitionId) {
    return repository.getCompetitionParticipants(competitionId);
  }
}