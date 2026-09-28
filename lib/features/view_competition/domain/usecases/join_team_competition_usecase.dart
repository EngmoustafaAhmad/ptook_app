import 'package:ptook/features/view_competition/domain/repositories/team/i_view_team_repository.dart';
import '../../../../core/utils/result.dart';

class JoinTeamCompetitionUseCase {
  final IViewTeamRepository repository;

  JoinTeamCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.joinTeamCompetition(competitionId);
  }
}