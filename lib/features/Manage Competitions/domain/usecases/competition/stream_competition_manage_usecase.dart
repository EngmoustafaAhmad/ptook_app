import '../../../../shared/domain/entities/competition_entity.dart';
import '../../repositories/i_manage_competition_repository.dart';

class StreamCompetitionManageUseCase {
  final IManageCompetitionRepository repository;

  StreamCompetitionManageUseCase(this.repository);

  Stream<CompetitionEntity> call(String competitionId) {
    return repository.streamCompetition(competitionId);
  }
}