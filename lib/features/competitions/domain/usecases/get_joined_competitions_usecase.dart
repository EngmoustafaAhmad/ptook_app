import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetJoinedCompetitionsUseCase {
  final ICompetitionRepository repository;

  GetJoinedCompetitionsUseCase(this.repository);

  Future<Either<Failure, List<CompetitionEntity>>> call({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    return await repository.getJoinedCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}