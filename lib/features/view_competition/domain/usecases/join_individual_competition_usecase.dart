import 'package:ptook/features/view_competition/domain/repositories/participant/i_view_participant_repository.dart';
import '../../../../core/utils/result.dart';

class JoinIndividualCompetitionUseCase {
  final IViewParticipantRepository repository;

  JoinIndividualCompetitionUseCase(this.repository);

  Future<Result<void>> call(String competitionId) {
    return repository.joinIndividualCompetition(competitionId);
  }
}