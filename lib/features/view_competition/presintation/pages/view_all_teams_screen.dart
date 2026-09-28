import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/presintation/pages/view_team_members_screen.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_state.dart';
import 'package:ptook/features/view_competition/presintation/widgets/team_expansion_card.dart';

class ViewAllTeamsScreen extends StatelessWidget {
  final CompetitionEntity competition;
  final List<TeamEntity>? initialTeams;
  final String currentUserId;
  final Function({
    required BuildContext context,
    required TeamEntity targetTeam,
    required bool isUserInThisTeam,
    required bool isUserInAnyTeam,
  })? onToggleJoin;

  const ViewAllTeamsScreen({
    super.key,
    required this.competition,
    required this.currentUserId,
    this.initialTeams,
    this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
      listenWhen: (previous, current) =>
          current is JoinCompetitionSuccess ||
          current is LeaveCompetitionSuccess ||
          current is ViewParticipantsError,
      listener: (context, state) {
        if (state is ViewParticipantsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.privateRed,
            ),
          );
        } else if (state is JoinCompetitionSuccess ||
            state is LeaveCompetitionSuccess) {
          final message = state is JoinCompetitionSuccess
              ? state.message
              : (state as LeaveCompetitionSuccess).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.publicGreen,
            ),
          );
        }
      },
      builder: (context, participantsState) {
        final isActionLoading =
            participantsState is ViewParticipantsActionLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'All Teams',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: isActionLoading
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(2),
                    child: LinearProgressIndicator(
                      color: AppColors.primaryPurple,
                      backgroundColor: Colors.transparent,
                    ),
                  )
                : null,
          ),
          body: BlocBuilder<ViewTeamsCubit, ViewTeamsState>(
            builder: (context, teamsState) {
              final currentTeams = (teamsState is ViewTeamsLoaded)
                  ? teamsState.teams
                  : (initialTeams ?? <TeamEntity>[]);

              final sortedTeams = List<TeamEntity>.from(currentTeams)
                ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

              final userCurrentTeam = sortedTeams.cast<TeamEntity?>().firstWhere(
                    (t) =>
                        t?.members.any((m) =>
                            m.id == currentUserId || m.userId == currentUserId) ??
                        false,
                    orElse: () => null,
                  );

              final bool isUserInAnyTeam = userCurrentTeam != null;

              if (sortedTeams.isEmpty) {
                return const Center(
                  child: Text(
                    'No teams found.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sortedTeams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final team = sortedTeams[index];
                  final rank = index + 1;
                  final isUserInThisTeam = userCurrentTeam?.id == team.id;

                  return GestureDetector(
                    onTap: () => _navigateToTeamMembers(context, team),
                    child: TeamExpansionCard(
                      key: ValueKey(team.id),
                      team: team,
                      rank: rank,
                      isJoined: isUserInThisTeam,
                      hasJoinedOtherTeam: isUserInAnyTeam && !isUserInThisTeam,
                      currentUserId: currentUserId,
                      isCompetitionEnded: competition.isFinished,
                      maxMembersLimit: _getCapacityLimit(team),
                      isActionPending: isActionLoading,
                      onToggleJoin: () {
                        if (onToggleJoin != null) {
                          onToggleJoin!(
                            context: context,
                            targetTeam: team,
                            isUserInThisTeam: isUserInThisTeam,
                            isUserInAnyTeam: isUserInAnyTeam,
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  int? _getCapacityLimit(TeamEntity team) {
    if (team.maxMembers != null && team.maxMembers! > 0) {
      return team.maxMembers;
    }
    if (competition.maxTeamMembers != null && competition.maxTeamMembers! > 0) {
      return competition.maxTeamMembers;
    }
    return null;
  }

  void _navigateToTeamMembers(BuildContext context, TeamEntity team) {
    ViewParticipantsCubit cubitToProvide;

    try {
      cubitToProvide = context.read<ViewParticipantsCubit>();
    } catch (_) {
      cubitToProvide = sl<ViewParticipantsCubit>();
    }

    cubitToProvide.listenToParticipants(competition.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubitToProvide,
          child: ViewTeamMembersScreen(
            team: team,
            competitionId: competition.id,
            ownerId: competition.ownerId,
          ),
        ),
      ),
    );
  }
}