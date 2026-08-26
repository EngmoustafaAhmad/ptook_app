import 'package:ptook/core/utils/result.dart';
import '../../repositories/i_manage_competition_repository.dart';

class RemoveMemberUseCase {
  final IManageCompetitionRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<Result<void>> call({
    required String competitionId,
    required String teamId,
    required String memberId,
  }) async {
    return await repository.removeMember(
      competitionId: competitionId,
      teamId: teamId,
      memberId: memberId,
    );
  }
}