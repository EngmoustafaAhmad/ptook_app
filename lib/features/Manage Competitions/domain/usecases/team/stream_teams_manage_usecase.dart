import 'package:ptook/features/Manage%20Competitions/domain/repositories/team/i_manage_team_repository.dart';

import '../../../../shared/domain/entities/team_entity.dart';

class StreamTeamsManageUseCase {
  final IManageTeamRepository repository;

  StreamTeamsManageUseCase(this.repository);

  Stream<List<TeamEntity>> call(String competitionId) {
    return repository.streamTeams(competitionId);
  }
}