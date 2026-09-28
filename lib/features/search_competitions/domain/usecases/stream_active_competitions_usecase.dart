import 'package:ptook/features/search_competitions/domain/entity/competition_page.dart';
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class StreamActiveCompetitionsParams {
  final CompetitionFilter filter;
  final String currentUserId;
  final int limit;
  final CompetitionCursor? startAfter;

  const StreamActiveCompetitionsParams({
    required this.filter,
    required this.currentUserId,
    this.limit = 10,
    this.startAfter,
  });
}

/// Real-time stream of active competitions (Stream Mode).
/// Used when the search query is empty.
class StreamActiveCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;

  StreamActiveCompetitionsUseCase(this._repository);

  Stream<CompetitionPage<CompetitionEntity>> call(
    StreamActiveCompetitionsParams params,
  ) {
    return _repository.streamActiveCompetitions(
      filter: params.filter,
      currentUserId: params.currentUserId,
      limit: params.limit,
      startAfter: params.startAfter,
    );
  }
}