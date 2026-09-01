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

  Future<Result<CompetitionEntity>> getCompetitionDetails({
    required String competitionId,
    required String userId,
  });

  // Favorites Actions
  Future<Result<void>> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  });

  Future<Result<bool>> isFavorite({
    required String userId,
    required String competitionId,
  });
  
  Future<Result<List<String>>> getFavoriteCompetitionIds(String userId);

  Future<Result<List<CompetitionEntity>>> getFavoriteCompetitions({
    required String userId,
    int limit = 10,
    String? lastCompetitionId,
  });

  // Participant Queries
  Future<Result<List<ParticipantEntity>>> getParticipants(
    String competitionId,
  );

  // Competition Participant Actions (Modifies competition.participantsCount)
  Future<Result<void>> joinIndividualCompetition(String competitionId);

  Future<Result<void>> leaveIndividualCompetition(String competitionId);

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

  Future<Result<void>> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  });

  // Realtime Streams
  Stream<CompetitionEntity> streamCompetition({
    required String competitionId,
    required String userId,
  });

  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  Stream<List<TeamEntity>> streamTeams(String competitionId);

  Stream<List<String>> streamFavoriteCompetitionIds(String userId);
}