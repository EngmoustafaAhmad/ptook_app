import '../../../../core/utils/result.dart';
import '../entities/competition_entity.dart';
import '../../../view_competition/domain/repositories/i_view_competition_repository.dart';

class GetCompetitionDetailsUseCase {
  final IViewCompetitionRepository repository;

  GetCompetitionDetailsUseCase(this.repository);

  Future<Result<CompetitionEntity>> call({
    required String competitionId,
    required String userId,
  }) {
    return repository.getCompetitionDetails(
      competitionId: competitionId,
      userId: userId,
    );
  }
}