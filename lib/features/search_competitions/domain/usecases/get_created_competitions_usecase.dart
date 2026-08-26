import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../repositories/i_search_competition_repository.dart';

class StreamCreatedCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;

  StreamCreatedCompetitionsUseCase(this._repository);

  Stream<List<CompetitionEntity>> call({
    String? query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _repository.streamCreatedCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}