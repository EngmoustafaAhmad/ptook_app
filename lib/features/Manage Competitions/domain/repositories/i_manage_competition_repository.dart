import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';
import '../../../shared/domain/entities/participant_entity.dart';
import '../../../shared/domain/entities/team_entity.dart';

abstract class IManageCompetitionRepository {
  // Organizer Dashboard Fetching
  Future<Result<List<CompetitionEntity>>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  // Competition Administration
  Future<Result<void>> createCompetition(
    CompetitionEntity competition,
  );

  Future<Result<void>> updateCompetition(
    CompetitionEntity competition,
  );

  Future<Result<void>> deleteCompetition(String competitionId);

  Future<Result<void>> finishCompetition(String competitionId);

  // Participant Management
  Future<Result<void>> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });

  Future<Result<void>> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  // Team Administration
  Future<Result<void>> createTeam(TeamEntity team);

  Future<Result<void>> deleteTeam({
    required String competitionId,
    required String teamId,
  });

  Future<Result<void>> removeMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  });

  Future<Result<void>> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  });

  // Realtime Streams
  Stream<CompetitionEntity> streamCompetition(String competitionId);

  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  Stream<List<TeamEntity>> streamTeams(String competitionId);
}