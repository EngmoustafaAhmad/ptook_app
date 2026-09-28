import 'package:ptook/features/shared/data/models/team_model.dart';

abstract class IViewTeamReamoteDataSource {
  Future<void> joinTeamCompetition(String competitionId);

  Future<void> leaveTeamCompetition(String competitionId);

  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  });

  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
  });

  Stream<List<TeamModel>> streamTeams(String competitionId);
}