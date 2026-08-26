import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class LeaveCompetitionUseCase {
  final IViewCompetitionRepository repository;

  LeaveCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.leaveCompetition(competitionId);
  }
}