import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class CreateTeamUseCase {
  final IManageCompetitionRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Result<void>> call(TeamEntity team) async {
    return await repository.createTeam(team);
  }
}