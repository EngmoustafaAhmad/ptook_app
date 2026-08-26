import 'package:ptook/features/shared/data/models/competition_model.dart';
import 'package:ptook/features/shared/data/models/participant_model.dart';
import 'package:ptook/features/shared/data/models/team_model.dart';

abstract class IViewCompetitionRemoteDataSource {
  // Discovery & Fetching
  Future<List<CompetitionModel>> getCompetitions();

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

  Future<CompetitionModel> getCompetitionById(String competitionId);
  Future<CompetitionModel> getCompetitionDetails(String competitionId);
  Future<CompetitionModel?> getCompetitionByCode(String code);

  // Participant Actions
  Future<List<ParticipantModel>> getParticipants(String competitionId);
  Future<void> joinCompetition(String competitionId);
  Future<void> leaveCompetition(String competitionId);

  // Team Interaction Actions
  Future<TeamModel> createTeam({
    required String competitionId,
    required String name,
    required bool isPrivate,
    String? joinCode,
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

  // Real-time Streams
  Stream<CompetitionModel> streamCompetition(String competitionId);
  Stream<List<ParticipantModel>> streamParticipants(String competitionId);
  Stream<List<TeamModel>> streamTeams(String competitionId);
}