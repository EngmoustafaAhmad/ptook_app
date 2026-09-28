import 'package:ptook/features/view_competition/domain/repositories/participant/i_view_participant_repository.dart';
import '../../../../core/utils/result.dart';

class LeaveIndividualCompetitionUseCase {
  final IViewParticipantRepository repository;

  LeaveIndividualCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.leaveIndividualCompetition(competitionId);
  }
}