import 'package:ptook/core/utils/result.dart'; // Adjust import path to your Result class
import 'package:ptook/features/search_competitions/domain/repositories/i_search_competition_repository.dart';

class JoinCompetitionSearchUseCase {
  final ISearchCompetitionRepository repository;

  const JoinCompetitionSearchUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String userId,
    String? joinCode,
  }) async {
    return await repository.joinCompetition(
      competitionId: competitionId,
      userId: userId,
      joinCode: joinCode,
    );
  }
}