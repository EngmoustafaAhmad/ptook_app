import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';
import '../../../shared/domain/entities/participant_entity.dart';
import '../../../shared/domain/entities/team_entity.dart';

abstract class IViewCompetitionRepository {
  // Discovery & Fetching
  Future<Result<List<CompetitionEntity>>> getCompetitions();

  Future<Result<List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Result<List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Result<List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Result<CompetitionEntity>> getCompetitionById(
    String competitionId,
  );

  Future<Result<CompetitionEntity?>> getCompetitionByCode(
    String code,
  );

  Future<Result<CompetitionEntity>> getCompetitionDetails(
    String competitionId,
  );

  // Participant Queries
  Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  );

  // Participant Actions
  Future<Result<void>> joinCompetition(String competitionId);

  Future<Result<void>> leaveCompetition(String competitionId);

  // Team Interaction Actions
  Future<Result<TeamEntity>> createTeam({
    required String competitionId,
    required String name,
    required bool isPrivate,
    String? joinCode,
  });

  Future<Result<void>> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  });

  Future<Result<void>> leaveTeam({
    required String competitionId,
    required String teamId,
  });

  Future<Result<void>> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  });

  // Realtime Streams
  Stream<CompetitionEntity> streamCompetition(String competitionId);

  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  Stream<List<TeamEntity>> streamTeams(String competitionId);
}