import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_state.dart';
import 'package:ptook/features/view_competition/presintation/widgets/team_expansion_card.dart';



class CompetitionTeamHomeView extends StatelessWidget {
  final CompetitionEntity competition;
  final String currentUserId;
  final String currentUserName;

  const CompetitionTeamHomeView({
    super.key,
    required this.competition,
    required this.currentUserId,
    this.currentUserName = 'Current User',
  });

  int? _getCapacityLimit(TeamEntity team) {
    if (team.maxMembers != null && team.maxMembers! > 0) {
      return team.maxMembers;
    }
    if (competition.maxTeamMembers != null &&
        competition.maxTeamMembers! > 0) {
      return competition.maxTeamMembers;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ManageCompetitionCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<ViewTeamsCubit>()..streamTeams(competition.id),
        ),
        BlocProvider(
          create: (context) => sl<ViewParticipantsCubit>()
            ..listenToParticipants(competition.id),
        ),
      ],
      child: BlocConsumer<ManageCompetitionCubit, ManageCompetitionState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null || current.successMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.privateRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.publicGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, cubitState) {
          final isLoading =
              cubitState.status == ManageCompetitionStatus.loading ||
                  cubitState.status == ManageCompetitionStatus.actionInProgress;

          final isCompetitionEnded =
              cubitState.isFinished || competition.isFinished;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: false,
              title: Text(
                competition.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              bottom: isLoading
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
                if (teamsState is ViewTeamsLoading ||
                    teamsState is ViewTeamsInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }

                if (teamsState is ViewTeamsError) {
                  return _buildErrorState(teamsState.message);
                }

                final teams =
                    (teamsState is ViewTeamsLoaded) ? teamsState.teams : <TeamEntity>[];

                final sortedTeams = List<TeamEntity>.from(teams)
                  ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

                final topThree = sortedTeams.take(3).toList();

                final userCurrentTeam =
                    sortedTeams.cast<TeamEntity?>().firstWhere(
                          (t) =>
                              t?.members.any((m) => m.id == currentUserId) ??
                              false,
                          orElse: () => null,
                        );

                final bool isUserInAnyTeam = userCurrentTeam != null;
                final bool hasNoTeams = sortedTeams.isEmpty;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCompetitionEnded && topThree.isNotEmpty) ...[
                        _buildPodiumContainer(topThree),
                        const SizedBox(height: 24),
                      ],
                      if (hasNoTeams) ...[
                        _buildEmptyState(),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCompetitionEnded
                                  ? 'Final Standings'
                                  : 'Team Leaderboard',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${sortedTeams.length} Teams',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedTeams.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final team = sortedTeams[index];
                            final isUserInThisTeam =
                                userCurrentTeam?.id == team.id;

                            return TeamExpansionCard(
                              team: team,
                              rank: index + 1,
                              isJoined: isUserInThisTeam,
                              hasJoinedOtherTeam: isUserInAnyTeam &&
                                  !isUserInThisTeam,
                              currentUserId: currentUserId,
                              isCompetitionEnded: isCompetitionEnded,
                              maxMembersLimit: _getCapacityLimit(team),
                              isActionPending: isLoading,
                              onToggleJoin: () => _handleJoinLeave(
                                context: context,
                                targetTeam: team,
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
            bottomNavigationBar: isCompetitionEnded
                ? null
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border(
                        top: BorderSide(color: AppColors.borderOutline),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.privateRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.privateRed,
                                width: 1.5,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                          label: const Text(
                            'Leave Competition',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          onPressed: () => _handleLeaveCompetition(context),
                        ),
                      )
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _handleLeaveCompetition(BuildContext context) async {
    final bool? confirm = await _showConfirmationDialog(
      context,
      title: 'Leave Competition?',
      message:
          'Are you sure you want to leave this competition? You will be removed from your team (if assigned) and lose access to all competition data.',
      confirmText: 'Leave',
      confirmColor: AppColors.privateRed,
    );

    if (confirm == true && context.mounted) {
      final viewParticipantsCubit = context.read<ViewParticipantsCubit>();
      
      await viewParticipantsCubit.leaveTeamCompetition(
        competitionId: competition.id,
        userId: currentUserId,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleJoinLeave({
    required BuildContext context,
    required TeamEntity targetTeam,
  }) async {
    final viewParticipantsCubit = context.read<ViewParticipantsCubit>();

    final participantsState = viewParticipantsCubit.state;
    final List<ParticipantEntity> participants =
        participantsState is ViewParticipantsLoaded
            ? participantsState.participants
            : <ParticipantEntity>[];

    final currentParticipant = participants.cast<ParticipantEntity?>().firstWhere(
          (p) => p?.userId == currentUserId,
          orElse: () => null,
        );

    final String? currentTeamId = currentParticipant?.teamId;

    if (currentTeamId == targetTeam.id) {
      final bool? confirmLeave = await _showConfirmationDialog(
        context,
        title: 'Leave Team?',
        message: 'Are you sure you want to leave "${targetTeam.name}"?',
        confirmText: 'Leave',
        confirmColor: Colors.redAccent,
      );

      if (confirmLeave == true && context.mounted) {
        viewParticipantsCubit.leaveTeam(
          competitionId: competition.id,
          teamId: targetTeam.id,
        );
      }
      return;
    }

    final capacityLimit = _getCapacityLimit(targetTeam);
    final isFull =
        capacityLimit != null && targetTeam.members.length >= capacityLimit;

    if (isFull) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This team has reached its maximum member limit.'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final bool isSwitching = currentTeamId != null && currentTeamId.isNotEmpty;
    if (isSwitching) {
      final bool? confirmSwitch = await _showConfirmationDialog(
        context,
        title: 'Switch Team?',
        message:
            'You are currently assigned to another team. You can only participate in one team at a time.\n\nDo you want to switch to "${targetTeam.name}"?',
        confirmText: 'Switch Team',
        confirmColor: AppColors.primaryPurple,
      );

      if (confirmSwitch != true) return;
    }

    final bool isPrivate = targetTeam.isPrivate;
    String? joinCode;

    if (isPrivate) {
      joinCode = await _showJoinCodeDialog(context, targetTeam.name);
      if (joinCode == null || joinCode.trim().isEmpty) return;

      final String expectedCode = targetTeam.joinCode ?? '';
      if (expectedCode.isNotEmpty && joinCode.trim() != expectedCode.trim()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid team join code. Access denied.'),
              backgroundColor: AppColors.privateRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    if (isSwitching) {
      await viewParticipantsCubit.leaveTeam(
        competitionId: competition.id,
        teamId: currentTeamId,
      );
    }

    if (context.mounted) {
      viewParticipantsCubit.joinTeam(
        competitionId: competition.id,
        teamId: targetTeam.id,
        joinCode: joinCode,
      );
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderOutline),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumContainer(List<TeamEntity> topThree) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🏆 Final Podium Winners',
                style: TextStyle(
                  color: AppColors.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: second != null
                    ? _buildPodiumAvatar(
                        team: second,
                        rank: 2,
                        accentColor: AppColors.silverAccent,
                        avatarSize: 60,
                        isCenter: false,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: first != null
                    ? _buildPodiumAvatar(
                        team: first,
                        rank: 1,
                        accentColor: AppColors.goldAccent,
                        avatarSize: 80,
                        isCenter: true,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: third != null
                    ? _buildPodiumAvatar(
                        team: third,
                        rank: 3,
                        accentColor: AppColors.bronzeAccent,
                        avatarSize: 55,
                        isCenter: false,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar({
    required TeamEntity team,
    required int rank,
    required Color accentColor,
    required double avatarSize,
    required bool isCenter,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: isCenter ? 3 : 2,
                ),
                boxShadow: isCenter
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.borderOutline,
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCenter ? 24 : 18,
                  ),
                ),
              ),
            ),
            Positioned(
              top: isCenter ? -4 : 4,
              child: isCenter
                  ? const Icon(
                      Icons.workspace_premium,
                      color: AppColors.goldAccent,
                      size: 28,
                    )
                  : Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 1.5),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isCenter ? FontWeight.bold : FontWeight.w600,
            fontSize: isCenter ? 15 : 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${team.totalPoints} pts',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: isCenter ? 14 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 48),
          Icon(Icons.groups_outlined, size: 64, color: Colors.white38),
          SizedBox(height: 12),
          Text(
            'No teams available in this competition yet.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Error loading team data:\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _JoinCodeDialog extends StatefulWidget {
  final String teamName;

  const _JoinCodeDialog({required this.teamName});

  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderOutline),
      ),
      title: Text(
        'Join ${widget.teamName}',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This is a private team. Enter the team join code to gain access:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter Code',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderOutline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryPurple),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
          ),
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

Future<String?> _showJoinCodeDialog(BuildContext context, String teamName) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _JoinCodeDialog(teamName: teamName),
  );
}