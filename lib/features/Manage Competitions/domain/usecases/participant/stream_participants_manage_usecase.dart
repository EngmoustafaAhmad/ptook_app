import '../../../../shared/domain/entities/participant_entity.dart';
import '../../repositories/i_manage_competition_repository.dart';

class StreamParticipantsManageUseCase {
  final IManageCompetitionRepository repository;

  StreamParticipantsManageUseCase(this.repository);

  Stream<List<ParticipantEntity>> call(String competitionId) {
    return repository.streamParticipants(competitionId);
  }
}