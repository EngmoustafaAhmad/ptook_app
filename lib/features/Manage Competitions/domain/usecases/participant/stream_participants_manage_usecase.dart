import 'package:ptook/features/Manage%20Competitions/domain/repositories/participant/i_manage_participant_repository.dart';

import '../../../../shared/domain/entities/participant_entity.dart';

class StreamParticipantsManageUseCase {
  final IManageParticipantRepository repository;

  StreamParticipantsManageUseCase(this.repository);

  Stream<List<ParticipantEntity>> call(String competitionId) {
    return repository.streamParticipants(competitionId);
  }
}