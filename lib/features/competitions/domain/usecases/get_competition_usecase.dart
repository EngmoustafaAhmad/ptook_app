import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetCompetitionsUseCase {
  final ICompetitionRepository repository;

  GetCompetitionsUseCase(this.repository);

  /// Executes the use case to fetch public competitions.
  Future<Either<Failure, List<CompetitionEntity>>> call() async {
    return await repository.getPublicCompetitions();
  }
}