import 'package:dartz/dartz.dart';

import 'package:ptook/core/errors/failures.dart';

import '../repositories/i_competition_repository.dart'; // Adjust path if needed

class DeleteCompetitionUseCase {
  final ICompetitionRepository repository;

  DeleteCompetitionUseCase(this.repository);

  Future<Either<Failure, void>> call(String competitionId) async {
    return await repository.deleteCompetition(competitionId);
  }
}