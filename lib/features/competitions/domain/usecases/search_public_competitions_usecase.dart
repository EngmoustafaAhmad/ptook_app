import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class SearchPublicCompetitionsUseCase {
  final ICompetitionRepository repository;

  SearchPublicCompetitionsUseCase(this.repository);

  /// Searches public competitions by keyword, or returns all public competitions if search term is empty.
  Future<Either<Failure, List<CompetitionEntity>>> call(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) {
      return await repository.getPublicCompetitions();
    }
    return await repository.searchPublicCompetitions(cleanKeyword);
  }
}