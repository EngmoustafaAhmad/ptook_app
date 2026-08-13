import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class SearchPublicCompetitionsUseCase {
  final ICompetitionRepository repository;

  SearchPublicCompetitionsUseCase(this.repository);

  /// Searches public competitions by keyword or fetches default public list with pagination support.
  Future<Either<Failure, List<CompetitionEntity>>> call({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    final cleanKeyword = query.trim().toLowerCase();

    if (cleanKeyword.isEmpty) {
      return await repository.getPublicCompetitions(
        limit: limit,
        lastCompetitionId: lastCompetitionId,
      );
    }

    return await repository.searchPublicCompetitions(
      query: cleanKeyword,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}