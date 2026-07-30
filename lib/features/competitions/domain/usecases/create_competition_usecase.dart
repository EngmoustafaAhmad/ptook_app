// lib/features/competitions/domain/usecases/create_competition_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class CreateCompetitionUseCase {
  final ICompetitionRepository repository;

  CreateCompetitionUseCase({required this.repository});

  Future<Either<String, Unit>> call(CompetitionEntity competition) async {
    return await repository.createCompetition(competition);
  }
}