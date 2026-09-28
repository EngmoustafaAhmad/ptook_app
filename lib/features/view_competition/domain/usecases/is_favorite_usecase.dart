import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/view_competition/domain/repositories/competition/i_view_competition_repository.dart';

class IsFavoriteUseCase {
  final IViewCompetitionRepository repository;

  IsFavoriteUseCase(this.repository);

  Future<Result<bool>> call({
    required String userId,
    required String competitionId,
  }) {
    return repository.isFavorite(userId: userId, competitionId: competitionId);
  }
}