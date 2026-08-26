import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';


class CreateCompetitionUseCase {
  final IManageCompetitionRepository repository;

  CreateCompetitionUseCase(this.repository);

  Future<Result<void>> call(CompetitionEntity competition) async {
    if (competition.name.trim().isEmpty) {
      return const Failure('Competition name cannot be empty.');
    }

    return await repository.createCompetition(competition);
  }
}