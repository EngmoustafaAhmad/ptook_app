import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetCompetitionByCodeUseCase {
  final ICompetitionRepository repository;

  GetCompetitionByCodeUseCase(this.repository);

  /// Executes the use case to fetch a competition by invite code.
  Future<Either<Failure, CompetitionEntity?>> call(String code) async {
    final cleanCode = code.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      return const Left(
        ServerFailure('Invite code cannot be empty.'), // Adjust to named parameter `ServerFailure(message: ...)` if your Failure class requires named args
      );
    }

    return await repository.getCompetitionByCode(cleanCode);
  }
}