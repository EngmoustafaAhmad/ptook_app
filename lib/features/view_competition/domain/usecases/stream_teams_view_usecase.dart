import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';

class StreamTeamsViewUseCase {
  final IViewTeamRepository repository;

  StreamTeamsViewUseCase(this.repository);

  Stream<List<TeamEntity>> call(String competitionId) {
    return repository.streamTeams(competitionId);
  }
}