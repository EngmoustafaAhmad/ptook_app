import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/domain/repositories/i_view_competition_repository.dart';

class StreamParticipantsViewUseCase {
  final IViewCompetitionRepository repository;

  StreamParticipantsViewUseCase(this.repository);

  Stream<List<ParticipantEntity>> call(String competitionId) {
    return repository.streamParticipants(competitionId);
  }
}