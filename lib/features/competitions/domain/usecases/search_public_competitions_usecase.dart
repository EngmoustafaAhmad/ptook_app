import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class SearchPublicCompetitionsUseCase {
  final ICompetitionRepository repository;

  SearchPublicCompetitionsUseCase(this.repository);

  Future<List<CompetitionEntity>> call(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) {
      return await repository.getPublicCompetitions();
    }
    return await repository.searchPublicCompetitions(cleanKeyword);
  }
}