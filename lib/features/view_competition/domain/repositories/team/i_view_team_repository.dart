import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

abstract class IViewTeamRepository {
  Future<Result<void>> joinTeamCompetition(String competitionId);

  Future<Result<void>> leaveTeamCompetition(String competitionId);

  // Team Membership Actions (Modifies team.membersCount)
  Future<Result<void>> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  });

  Future<Result<void>> leaveTeam({
    required String competitionId,
    required String teamId,
  });

  Stream<List<TeamEntity>> streamTeams(String competitionId);
}