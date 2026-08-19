import 'package:ptook/features/competitions/data/models/competition_model.dart';
import 'package:ptook/features/competitions/data/models/team_model.dart';
import 'package:ptook/features/participants/data/models/participant_model.dart';

abstract class ICompetitionRemoteDataSource {
  Future<List<CompetitionModel>> getCompetitions();
  Future<CompetitionModel> getCompetitionById(String competitionId);
  Future<CompetitionModel> getCompetitionDetails(String competitionId);
  Future<CompetitionModel?> getCompetitionByCode(String code);
  Future<void> createCompetition(CompetitionModel competition);
  Future<void> updateCompetition(CompetitionModel competition);
  Future<void> deleteCompetition(String competitionId);
  Future<void> joinCompetition(String competitionId);
  Future<void> leaveCompetition(String competitionId);

  // Management Actions
  Future<void> finishCompetition(String competitionId);
  Future<void> updateParticipantPoints({
    required String competitionId,
    required String participantId,
    required int addedPoints,
  });
  Future<void> removeParticipant({
    required String competitionId,
    required String participantId,
  });

  // Team Management Actions
  Future<TeamModel> createTeam({
    required String competitionId,
    required String name,
    required bool isPrivate,
    String? joinCode,
  });
  Future<void> deleteTeam({
    required String competitionId,
    required String teamId,
  });
  Future<void> joinTeam({
    required String competitionId,
    required String teamId,
    String? joinCode,
  });
  Future<void> leaveTeam({
    required String competitionId,
    required String teamId,
  });
  Future<void> switchTeam({
    required String competitionId,
    required String fromTeamId,
    required String toTeamId,
    String? joinCode,
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

  // Paginated Fetching & Search
  Future<List<CompetitionModel>> getPublicCompetitions({
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> searchPublicCompetitions({
    String query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> getJoinedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  Future<List<CompetitionModel>> getCreatedCompetitions({
    String? query = '',
    int limit = 10,
    String? lastCompetitionId,
  });

  // Realtime Streams
  Stream<CompetitionModel> streamCompetition(String competitionId);
  Stream<List<ParticipantModel>> streamParticipants(String competitionId);
  Stream<List<TeamModel>> streamTeams(String competitionId);
}