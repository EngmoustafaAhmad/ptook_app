import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

abstract class ICompetitionRepository {
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions();

  Future<Either<Failure, List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Either<Failure, List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Either<Failure, List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Either<Failure, List<CompetitionEntity>>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<Either<Failure, CompetitionEntity>> getCompetitionById(
      String competitionId);

  Future<Either<Failure, CompetitionEntity?>> getCompetitionByCode(String code);

  Future<Either<Failure, CompetitionEntity>> getCompetitionDetails(
      String competitionId);

  Future<Either<Failure, void>> createCompetition(CompetitionEntity competition);

  Future<Either<Failure, void>> updateCompetition(CompetitionEntity competition);

  Future<Either<Failure, void>> deleteCompetition(String competitionId);

  Future<Either<Failure, void>> joinCompetition(String competitionId);

  Future<Either<Failure, void>> leaveCompetition(String competitionId);

  // ===========================================================================
  // MANAGEMENT ACTIONS
  // ===========================================================================

  Future<Either<Failure, void>> finishCompetition(String competitionId);

  Future<Either<Failure, void>> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });

  Future<Either<Failure, void>> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  // ===========================================================================
  // TEAM MANAGEMENT ACTIONS
  // ===========================================================================

  /// Returns created [TeamEntity] on success
  Future<Either<Failure, TeamEntity>> createTeam({
    required String competitionId,
    required String name,
    required bool isPrivate,
    String? joinCode,
  });

  Future<Either<Failure, void>> deleteTeam({
    required String competitionId,
    required String teamId,
  });
  Future<Either<Failure, void>> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  });

  Future<Either<Failure, void>> leaveTeam({
    required String competitionId,
    required String teamId,
  });

  /// Atomically leaves [fromTeamId] and joins [toTeamId] in a single transaction.
  Future<Either<Failure, void>> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  });


  Future<Either<Failure, void>> removeMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  });

  Future<Either<Failure, void>> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  });

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================

  Stream<CompetitionEntity> streamCompetition(String competitionId);

  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);

  Stream<List<TeamEntity>> streamTeams(String competitionId);
}