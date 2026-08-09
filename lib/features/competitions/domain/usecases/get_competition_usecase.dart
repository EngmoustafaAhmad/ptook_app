import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetCompetitionsUseCase {
  final ICompetitionRepository repository;

  GetCompetitionsUseCase(this.repository);

  Future<List<CompetitionEntity>> call() async {
    return await repository.getPublicCompetitions();
  }
}