import 'package:equatable/equatable.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

enum ManageCompetitionStatus {
  initial,
  loading,
  loaded,
  actionInProgress,
  actionSuccess,
  updated,
  finished,
  deleted,
  failure,
  error,
}

class ManageCompetitionState extends Equatable {
  final ManageCompetitionStatus status;
  final CompetitionEntity? competition;
  final List<ParticipantEntity> participants;
  final List<TeamEntity> teams;
  final String? expandedTeamId;
  final bool showAllTeams;
  final String? errorMessage;
  final String? successMessage;

  const ManageCompetitionState({
    this.status = ManageCompetitionStatus.initial,
    this.competition,
    this.participants = const [],
    this.teams = const [],
    this.expandedTeamId,
    this.showAllTeams = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Checks whether the competition is completed or in a finished state.
  bool get isFinished =>
      status == ManageCompetitionStatus.finished ||
      (competition?.isFinished ?? false);

  /// Computes total number of participants across direct participants or team members.
  int get totalParticipants => participants.isNotEmpty
      ? participants.length
      : teams.fold(0, (sum, team) => sum + team.members.length);

  /// Computes a sorted list of teams based on accumulated total points in descending order.
  List<TeamEntity> get rankedTeams {
    final sortedTeams = List<TeamEntity>.from(teams)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return sortedTeams;
  }

  ManageCompetitionState copyWith({
    ManageCompetitionStatus? status,
    CompetitionEntity? competition,
    List<ParticipantEntity>? participants,
    List<TeamEntity>? teams,
    String? expandedTeamId,
    bool? showAllTeams,
    String? errorMessage,
    String? successMessage,
  }) {
    return ManageCompetitionState(
      status: status ?? this.status,
      competition: competition ?? this.competition,
      participants: participants ?? this.participants,
      teams: teams ?? this.teams,
      expandedTeamId: expandedTeamId ?? this.expandedTeamId,
      showAllTeams: showAllTeams ?? this.showAllTeams,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        competition,
        participants,
        teams,
        expandedTeamId,
        showAllTeams,
        errorMessage,
        successMessage,
      ];
}