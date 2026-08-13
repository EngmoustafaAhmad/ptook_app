import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetPublicCompetitionsUseCase {
  final ICompetitionRepository repository;

  GetPublicCompetitionsUseCase(this.repository);

  /// Executes the use case to fetch public competitions with pagination support.
  Future<Either<Failure, List<CompetitionEntity>>> call({
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    return await repository.getPublicCompetitions(
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}