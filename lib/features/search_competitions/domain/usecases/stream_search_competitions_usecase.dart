import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../repositories/i_search_competition_repository.dart';

class StreamSearchCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;

  StreamSearchCompetitionsUseCase(this._repository);

  Stream<List<CompetitionEntity>> call({
    required String query,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _repository.streamSearchCompetitionsUseCase(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}