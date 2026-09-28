import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';
import '../../../../core/utils/result.dart';

class LeaveTeamCompetitionUseCase {
  final IViewTeamRepository repository;

  LeaveTeamCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.leaveTeamCompetition(competitionId);
  }
}