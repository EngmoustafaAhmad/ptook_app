import 'package:ptook/core/utils/result.dart';
import 'package:ptook/features/Manage%20Competitions/domain/repositories/i_manage_competition_repository.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class GetCreatedCompetitionsUseCase {
  final IManageCompetitionRepository repository;

  GetCreatedCompetitionsUseCase(this.repository);

  Future<Result<List<CompetitionEntity>>> call({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  }) async {
    return await repository.getCreatedCompetitions(
      query: query,
      limit: limit,
      lastCompetitionId: lastCompetitionId,
    );
  }
}