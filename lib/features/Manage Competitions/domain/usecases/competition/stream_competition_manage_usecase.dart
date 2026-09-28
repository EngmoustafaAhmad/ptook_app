import 'package:ptook/features/Manage%20Competitions/domain/repositories/competition/i_manage_competition_repository.dart';

import '../../../../shared/domain/entities/competition_entity.dart';

class StreamCompetitionManageUseCase {
  final IManageCompetitionRepository repository;

  StreamCompetitionManageUseCase(this.repository);

  Stream<CompetitionEntity> call(String competitionId) {
    return repository.streamCompetition(competitionId);
  }
}