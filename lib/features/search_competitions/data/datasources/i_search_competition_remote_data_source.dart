import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

abstract class ISearchCompetitionRemoteDataSource {
  /// Real-time stream of public competitions (paginated)
  Stream<List<CompetitionModel>> streamAllCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream for searching public competitions (paginated)
  Stream<List<CompetitionModel>> streamSearchCompetitions({
    required String query,
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream of competitions joined by current user (paginated)
  Stream<List<CompetitionModel>> streamJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Real-time stream of competitions created by current user (paginated)
  Stream<List<CompetitionModel>> streamCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Direct user participation actions
  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    String? joinCode,
  });
  
  Future<void> leaveCompetition(String competitionId);

  /// Additional management and lookup actions
  Future<CompetitionModel> getCompetitionById(String competitionId);
  Future<CompetitionModel> getCompetitionDetails(String competitionId);
  Future<CompetitionModel?> getCompetitionByCode(String code);
  Future<void> createCompetition(CompetitionModel competition);
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> finishCompetition(String competitionId);

  /// Participants and Teams data sources
  Future<List<ParticipantEntity>> getParticipants(String competitionId);
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);
  Stream<List<TeamEntity>> streamTeams(String competitionId);
}