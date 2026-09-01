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

  Future<CompetitionModel> getCompetitionDetails({
    required String competitionId,
    required String userId,
  });

  Future<CompetitionModel?> getCompetitionByCode(String code);

  // Favorites Actions
  Future<void> toggleFavorite({
    required String userId,
    required String competitionId,
    required bool isFavorite,
  });

  Future<bool> isFavorite({
    required String userId,
    required String competitionId,
  });

  Future<List<String>> getFavoriteCompetitionIds(String userId);

  Future<List<CompetitionModel>> getFavoriteCompetitions({
    required String userId,
    int limit = 10,
    String? lastCompetitionId,
  });

  // Participant Queries
  Future<List<ParticipantModel>> getParticipants(String competitionId);

  // Participant Competition Actions (Modifies competition.participantsCount)
  Future<void> joinIndividualCompetition(String competitionId);

  Future<void> leaveIndividualCompetition(String competitionId);

  Future<void> joinTeamCompetition(String competitionId);

  Future<void> leaveTeamCompetition(String competitionId);

  // Team Membership Actions (Modifies team.membersCount)
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
  Stream<CompetitionModel> streamCompetition({
    required String competitionId,
    required String userId,
  });

  Stream<List<ParticipantModel>> streamParticipants(String competitionId);

  Stream<List<TeamModel>> streamTeams(String competitionId);

  Stream<List<String>> streamFavoriteCompetitionIds(String userId);
}