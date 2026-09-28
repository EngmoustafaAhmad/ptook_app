import 'package:ptook/features/shared/data/models/team_model.dart';

abstract class IManageTeamRemoteDataSource {
  // Team Administration
  Future<void> createTeam(TeamModel team);

  Future<void> deleteTeam({
    required String competitionId,
    required String teamId,
  });

  Future<void> updateTeamParticipantPoints({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  });

  Future<void> removeTeamParticipant({
    required String competitionId,
    required String teamId,
    required String participantId,
  });

  // Realtime Streams
  Stream<List<TeamModel>> streamTeams(String competitionId);
}