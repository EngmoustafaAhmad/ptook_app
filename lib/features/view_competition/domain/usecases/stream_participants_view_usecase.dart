import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/domain/repositories/participant/i_view_participant_repository.dart';

class StreamParticipantsViewUseCase {
  final IViewParticipantRepository repository;

  StreamParticipantsViewUseCase(this.repository);

  Stream<List<ParticipantEntity>> call(String competitionId) {
    return repository.streamParticipants(competitionId);
  }
}