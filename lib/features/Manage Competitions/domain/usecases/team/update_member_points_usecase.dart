import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class UpdateMemberPointsUseCase {
  final IManageCompetitionRepository repository;

  UpdateMemberPointsUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  }) async {
    return await repository.updateMemberPoints(
      competitionId: competitionId,
      teamId: teamId,
      memberId: memberId,
      points: points,
    );
  }
}