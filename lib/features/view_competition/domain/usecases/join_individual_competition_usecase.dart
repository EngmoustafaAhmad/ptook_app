import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class JoinIndividualCompetitionUseCase {
  final IViewCompetitionRepository repository;

  JoinIndividualCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.joinIndividualCompetition(competitionId);
  }
}