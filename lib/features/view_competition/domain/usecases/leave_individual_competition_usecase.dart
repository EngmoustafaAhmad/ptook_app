import '../../../../core/utils/result.dart';
import '../repositories/i_view_competition_repository.dart';

class LeaveIndividualCompetitionUseCase {
  final IViewCompetitionRepository repository;

  LeaveIndividualCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.leaveIndividualCompetition(competitionId);
  }
}