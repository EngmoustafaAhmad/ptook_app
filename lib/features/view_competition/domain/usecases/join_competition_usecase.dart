import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class JoinCompetitionUseCase {
  final IViewCompetitionRepository repository;

  JoinCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.joinCompetition(competitionId);
  }
}