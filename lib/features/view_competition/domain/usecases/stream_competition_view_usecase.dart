import '../../../shared/domain/entities/competition_entity.dart';
import '../repositories/i_view_competition_repository.dart';

class StreamCompetitionViewUseCase {
  final IViewCompetitionRepository repository;

  StreamCompetitionViewUseCase(this.repository);

  Stream<CompetitionEntity> call(String competitionId) {
    return repository.streamCompetition(competitionId);
  }
}