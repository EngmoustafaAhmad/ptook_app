import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class LeaveTeamCompetitionUseCase {
  final IViewCompetitionRepository repository;

  LeaveTeamCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.leaveTeamCompetition(competitionId);
  }
}