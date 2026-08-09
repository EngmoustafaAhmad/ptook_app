import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

abstract class CompetitionRepository {
  /// Fetches a list of all active competitions.
  Future<Either<Failure, List<CompetitionEntity>>> getCompetitions();

  /// Fetches a single competition by its ID.
  Future<Either<Failure, CompetitionEntity>> getCompetitionById(String competitionId);

  /// Creates a new competition (for organizers).
  Future<Either<Failure, void>> createCompetition(CompetitionEntity competition);

  /// Updates an existing competition.
  Future<Either<Failure, void>> updateCompetition(CompetitionEntity competition);

  /// Deletes a competition.
  Future<Either<Failure, void>> deleteCompetition(String competitionId);
}