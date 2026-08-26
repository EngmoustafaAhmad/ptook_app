import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class StreamJoinedCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;
  StreamJoinedCompetitionsUseCase(this._repository);

  Stream<List<CompetitionEntity>> call({String? query, int limit = 10, String? lastCompetitionId}) {
    return _repository.streamJoinedCompetitions(query: query, limit: limit, lastCompetitionId: lastCompetitionId);
  }
}