import 'package:ptook/features/view_competition/domain/repositories/competition/i_view_competition_repository.dart';

import '../../../../core/utils/result.dart';

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