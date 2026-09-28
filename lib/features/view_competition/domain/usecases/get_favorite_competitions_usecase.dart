import 'package:ptook/features/view_competition/domain/repositories/competition/i_view_competition_repository.dart';

import '../../../../core/utils/result.dart';
import '../../../shared/domain/entities/competition_entity.dart';

class GetFavoriteCompetitionsUsecase {
  final IViewCompetitionRepository repository;

  GetFavoriteCompetitionsUsecase(this.repository);

  Future<Result<List<CompetitionEntity>>> call({
    required String userId,
    int limit = 10,
    String? lastCompetitionId,
  }) {
    return repository.getFavoriteCompetitions(
      userId: userId,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}