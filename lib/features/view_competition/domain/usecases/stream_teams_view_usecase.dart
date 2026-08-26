import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/domain/repositories/i_view_competition_repository.dart';

class StreamTeamsViewUseCase {
  final IViewCompetitionRepository repository;

  StreamTeamsViewUseCase(this.repository);

  Stream<List<TeamEntity>> call(String competitionId) {
    return repository.streamTeams(competitionId);
  }
}