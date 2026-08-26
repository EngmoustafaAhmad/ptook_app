import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';

import '../../../shared/data/models/participant_model.dart';

  abstract class IManageCompetitionRemoteDataSource {
    // Organizer Dashboard Fetching
    Future<List<CompetitionModel>> getCreatedCompetitions({
      String? query = '',
      int limit = 10,
      String? lastCompetitionId,
    });

  // Competition Administration
  Future<void> createCompetition(CompetitionModel competition);
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> finishCompetition(String competitionId);

  // Participant Management
  Future<void> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });

  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  // Team Administration
  Future<void> createTeam(TeamModel team);

  Future<void> deleteTeam({
    required String competitionId,
    required String teamId,
  });

  Future<void> removeMember({
    required String competitionId,
    required String teamId,
    required String memberId,
  });

  Future<void> updateMemberPoints({
    required String competitionId,
    required String teamId,
    required String memberId,
    required int points,
  });

  // Realtime Streams
  Stream<CompetitionModel> streamCompetition(String competitionId);
  Stream<List<ParticipantModel>> streamParticipants(String competitionId);
  Stream<List<TeamModel>> streamTeams(String competitionId);
}