import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

abstract class ISearchCompetitionRepository {
  // ===========================================================================
  // REAL-TIME FEEDS & SEARCH
  // ===========================================================================

  /// Real-time stream of public competitions
  Stream<List<CompetitionEntity>> streamAllCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream for searching public competitions
  Stream<List<CompetitionEntity>> streamSearchCompetitionsUseCase({
    required String query,
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream of competitions joined by current user
  Stream<List<CompetitionEntity>> streamJoinedCompetitions({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream of competitions created by current user
  Stream<List<CompetitionEntity>> streamCreatedCompetitions({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream of teams in a competition
  Stream<List<TeamEntity>> streamTeams(String competitionId);

  /// Real-time stream of participants in a competition
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  // ===========================================================================
  // PARTICIPANT & TEAM QUERIES
  // ===========================================================================

  Future<Result<List<ParticipantEntity>>> getParticipants(String competitionId);

  // ===========================================================================
  // COMPETITION ACTIONS & LOOKUPS
  // ===========================================================================

  Future<Result<CompetitionEntity>> getCompetitionById(String competitionId);

  Future<Result<CompetitionEntity?>> getCompetitionByCode(String code);

  Future<Result<CompetitionEntity>> getCompetitionDetails(String competitionId);

  Future<Result<void>> joinCompetition({
    required String competitionId,
    String? joinCode, 
    required String userId,
  });

  Future<Result<void>> leaveCompetition(String competitionId);

  Future<Result<void>> createCompetition(CompetitionEntity competition);

  Future<Result<void>> updateCompetition(CompetitionEntity competition);

  Future<Result<void>> deleteCompetition(String competitionId);

  Future<Result<void>> finishCompetition(String competitionId);
}