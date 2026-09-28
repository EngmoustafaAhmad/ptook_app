import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

abstract class IManageTeamRepository {
  // Team Administration
  Future<Result<void>> createTeam(TeamEntity team);

  Future<Result<void>> deleteTeam({
    required String competitionId,
    required String teamId,
  });

  Future<Result<void>> updateTeamParticipantPoints({
    required String competitionId,
    required String teamId,
    required String participantId,
    required int addedPoints,
  });

  Future<Result<void>> removeTeamParticipant({
    required String competitionId,
    required String teamId,
    required String participantId,
  });
  
  Stream<List<TeamEntity>> streamTeams(String competitionId);
}