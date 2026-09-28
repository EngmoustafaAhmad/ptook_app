import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class SearchActiveCompetitionsParams {
  final String query;
  final CompetitionFilter filter;
  final String currentUserId;
  final int limit;
  final CompetitionCursor? startAfter;

  const SearchActiveCompetitionsParams({
    required this.query,
    required this.filter,
    required this.currentUserId,
    this.limit = 10,
    this.startAfter,
  });
}

/// One-shot query search for active competitions (Search Mode).
/// Used when a user types a non-empty search query.
class SearchActiveCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;

  SearchActiveCompetitionsUseCase(this._repository);

  Future<Result<CompetitionPage<CompetitionEntity>>> call(
    SearchActiveCompetitionsParams params,
  ) {
    return _repository.searchActiveCompetitions(
      query: params.query,
      filter: params.filter,
      currentUserId: params.currentUserId,
      limit: params.limit,
      startAfter: params.startAfter,
    );
  }
}