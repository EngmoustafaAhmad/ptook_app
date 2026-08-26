// import 'package:dartz/dartz.dart';
// import 'package:ptook/core/errors/failures.dart';
// import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';

// class JoinTeamUseCase {
//   final ICompetitionRepository repository;

//   JoinTeamUseCase(this.repository);

//   Future<Either<Failure, void>> call({
//     required String competitionId,
//     required String teamId,
//     String? joinCode,
//   }) async {
//     return await repository.joinTeam(
//       competitionId: competitionId,
//       teamId: teamId,
//       joinCode: joinCode,
//     );
//   }
// }