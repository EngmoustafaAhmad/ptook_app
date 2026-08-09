import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class GetCompetitionByCodeUseCase {
  final ICompetitionRepository repository;

  GetCompetitionByCodeUseCase(this.repository);

  Future<Object?> call(String code) async {
    if (code.trim().isEmpty) {
      return const Left(
        ServerFailure(message: 'Invite code cannot be empty.'),
      );
    }
    return await repository.getCompetitionByCode(code.trim().toUpperCase());
  }
}