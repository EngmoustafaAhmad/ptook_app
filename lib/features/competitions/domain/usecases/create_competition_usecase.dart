import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class CreateCompetitionUseCase {
  final ICompetitionRepository repository;

  CreateCompetitionUseCase(this.repository);

  Future<void> call(CompetitionEntity competition) async {
    if (competition.name.trim().isEmpty) {
      throw ArgumentError('Competition name cannot be empty.');
    }
    
    await repository.createCompetition(competition);
  }
}