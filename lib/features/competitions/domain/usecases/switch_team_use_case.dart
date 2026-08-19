import 'package:dartz/dartz.dart';
import 'package:ptook/core/errors/failures.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

class SwitchTeamUseCase {
  final ICompetitionRepository repository;

  SwitchTeamUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
  }) async {
    return await repository.switchTeam(
      competitionId: competitionId,
      fromTeamId: fromTeamId,
      toTeamId: toTeamId,
      joinCode: joinCode,
    );
  }
}