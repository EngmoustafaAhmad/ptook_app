import '../../../../shared/domain/entities/team_entity.dart';
import '../../repositories/i_manage_competition_repository.dart';

class StreamTeamsManageUseCase {
  final IManageCompetitionRepository repository;

  StreamTeamsManageUseCase(this.repository);

  Stream<List<TeamEntity>> call(String competitionId) {
    return repository.streamTeams(competitionId);
  }
}