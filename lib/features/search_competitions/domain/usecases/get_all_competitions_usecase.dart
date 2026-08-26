import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

import '../repositories/i_search_competition_repository.dart';

class StreamPublicCompetitionsUseCase {
  final ISearchCompetitionRepository _repository;

  StreamPublicCompetitionsUseCase(this._repository);

  Stream<List<CompetitionEntity>> call({
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return _repository.streamAllCompetitions(
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}