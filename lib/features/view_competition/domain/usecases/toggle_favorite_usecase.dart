import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class ToggleFavoriteUsecase {
  final IViewCompetitionRepository repository;

  ToggleFavoriteUsecase(this.repository);

  Future<Result<void>> call({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  }) {
    return repository.toggleFavorite(
      userId: userId,
      competitionId: competitionId,
      isFavorite: isFavorite,
    );
  }
}