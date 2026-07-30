// lib/features/competitions/domain/repositories/i_competition_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

abstract class ICompetitionRepository {
  Future<Either<String, Unit>> createCompetition(CompetitionEntity competition);
}