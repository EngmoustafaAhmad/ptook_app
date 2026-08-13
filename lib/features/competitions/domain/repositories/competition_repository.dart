import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

abstract class CompetitionRepository {
  /// Fetches a list of all active competitions.
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions();

  /// Fetches all public competitions.
  Future<Either<Failure, List<CompetitionEntity>>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Searches public competitions by keyword.
  Future<Either<Failure, List<CompetitionEntity>>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Fetches competitions joined by the current user.
  Future<Either<Failure, List<CompetitionEntity>>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Fetches competitions created by the current user.
  Future<Either<Failure, List<CompetitionEntity>>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  /// Fetches a single competition by its ID.
  Future<Either<Failure, CompetitionEntity>> getCompetitionById(String competitionId);

  /// Fetches a single competition by its invite code (returns null if not found).
  Future<Either<Failure, CompetitionEntity?>> getCompetitionByCode(String code);

  Future<CompetitionEntity> getCompetitionDetails(String competitionId);
  
  /// Creates a new competition (for organizers).
  Future<Either<Failure, void>> createCompetition(CompetitionEntity competition);

  /// Updates an existing competition.
  Future<Either<Failure, void>> updateCompetition(CompetitionEntity competition);

  /// Deletes a competition.
  Future<Either<Failure, void>> deleteCompetition(String competitionId);

  /// Joins an existing competition.
  Future<Either<Failure, void>> joinCompetition(String competitionId);

  /// Leaves a competition.
  Future<Either<Failure, void>> leaveCompetition(String competitionId);

  // ===========================================================================
  // REALTIME STREAMS
  // ===========================================================================

  /// Realtime Stream for competition details (e.g., dynamic participant counts).
  Stream<CompetitionEntity> streamCompetition(String competitionId);

  /// Realtime Stream for participant leaderboards.
  Stream<List<ParticipantEntity>> streamParticipants(String competitionId);
}

