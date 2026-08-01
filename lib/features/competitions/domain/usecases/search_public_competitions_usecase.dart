 import '../entities/competition_entity.dart';
import '../repositories/i_competition_repository.dart';



class SearchPublicCompetitionsUseCase {


  final ICompetitionRepository repository;



  SearchPublicCompetitionsUseCase({
    required this.repository,
  });





  Future<List<CompetitionEntity>> call(
      String keyword,
  ) async {


    return await repository.searchPublicCompetitions(
      keyword,
    );


  }


}