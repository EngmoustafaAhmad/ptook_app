import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/team_entity.dart';

abstract class TeamManagementState extends Equatable {
  final List<TeamEntity> teams;
  final String? expandedTeamId;
  final bool showAllTeams;

  const TeamManagementState({
    this.teams = const [],
    this.expandedTeamId,
    this.showAllTeams = false,
  });

  /// Ranked teams sorted by total points descending
  List<TeamEntity> get rankedTeams {
    final sorted = List<TeamEntity>.from(teams);
    sorted.sort((a, b) => (b.totalPoints ?? 0).compareTo(a.totalPoints ?? 0));
    return sorted;
  }

  @override
  List<Object?> get props => [teams, expandedTeamId, showAllTeams];
}

class TeamManagementInitial extends TeamManagementState {
  const TeamManagementInitial();
}

class TeamManagementLoading extends TeamManagementState {
  const TeamManagementLoading({
    super.teams,
    super.expandedTeamId,
    super.showAllTeams,
  });
}

class TeamManagementLoaded extends TeamManagementState {
  const TeamManagementLoaded({
    super.teams,
    super.expandedTeamId,
    super.showAllTeams,
  });

  TeamManagementLoaded copyWith({
    List<TeamEntity>? teams,
    String? expandedTeamId,
    bool? showAllTeams,
  }) {
    return TeamManagementLoaded(
      teams: teams ?? this.teams,
      expandedTeamId: expandedTeamId ?? this.expandedTeamId,
      showAllTeams: showAllTeams ?? this.showAllTeams,
    );
  }
}

class TeamActionSuccess extends TeamManagementState {
  final String message;

  const TeamActionSuccess(
    this.message, {
    super.teams,
    super.expandedTeamId,
    super.showAllTeams,
  });

  @override
  List<Object?> get props => [message, teams, expandedTeamId, showAllTeams];
}

class TeamManagementFailure extends TeamManagementState {
  final String error;

  const TeamManagementFailure(
    this.error, {
    super.teams,
    super.expandedTeamId,
    super.showAllTeams,
  });

  @override
  List<Object?> get props => [error, teams, expandedTeamId, showAllTeams];
}