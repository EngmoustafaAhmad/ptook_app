import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class JoinTeamCompetitionUseCase {
  final IViewCompetitionRepository repository;

  JoinTeamCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.joinTeamCompetition(competitionId);
  }
}