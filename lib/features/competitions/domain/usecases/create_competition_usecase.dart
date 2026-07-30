import '../entities/competition_entity.dart';
import '../repositories/i_competition_repository.dart';


class CreateCompetitionUseCase {

  final ICompetitionRepository repository;


  CreateCompetitionUseCase({
    required this.repository,
  });



  Future<void> call(
      CompetitionEntity competition
  ){

    return repository.createCompetition(
      competition,
    );

  }

}