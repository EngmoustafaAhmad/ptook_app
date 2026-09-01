import '../../../shared/domain/entities/competition_entity.dart';
import '../repositories/i_view_competition_repository.dart';

class StreamCompetitionViewUseCase {
  final IViewCompetitionRepository repository;

  StreamCompetitionViewUseCase(this.repository);

  Stream<CompetitionEntity> call({
    required String competitionId,
    required String userId,
  }) {
    return repository.streamCompetition(
      competitionId: competitionId,
      userId: userId,
    );
  }
}