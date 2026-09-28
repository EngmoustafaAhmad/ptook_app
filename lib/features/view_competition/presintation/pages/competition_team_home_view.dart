import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/shared/presintation/widgets/custome_top_teams_widget.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_state.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/view_all_teams_screen.dart';
import 'package:ptook/features/view_competition/presintation/pages/view_team_members_screen.dart';
import 'package:ptook/features/view_competition/presintation/widgets/team_expansion_card.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDurationDays =
        competition.endDate.difference(competition.startDate).inDays;
    final daysRemaining = competition.endDate.difference(now).inDays;
    final displayDuration = daysRemaining >= 0 ? daysRemaining : 0;

    final daysPassed = now.difference(competition.startDate).inDays;
    final currentDayNumber = (daysPassed >= 0 ? daysPassed : 0) + 1;
    final totalDays = totalDurationDays > 0 ? totalDurationDays : 1;
    final progressRatio = (daysPassed / totalDays).clamp(0.0, 1.0);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<CompetitionHomeCubit>()
            ..loadCompetitionData(
              competition: competition,
              userId: currentUserId,
            ),
        ),
        BlocProvider(
          create: (context) =>
              sl<ViewTeamsCubit>()..streamTeams(competition.id),
        ),
        BlocProvider(
          create: (context) => sl<ViewParticipantsCubit>()
            ..listenToParticipants(competition.id),
        ),
      ],
      child: BlocBuilder<CompetitionHomeCubit, CompetitionHomeState>(
        builder: (context, homeState) {
          final isFavorite = homeState is CompetitionHomeLoaded
              ? homeState.isFavorite
              : competition.isFavorite;

          // 📊 Calculate actual user points and dynamic rank
          int userPoints = 0;
          int userRank = 0;

          if (homeState is CompetitionHomeLoaded &&
              homeState.participants.isNotEmpty) {
            final sortedParticipants =
                List.from(homeState.participants)
                  ..sort((a, b) => (b.points ?? 0).compareTo(a.points ?? 0));

            final userIndex =
                sortedParticipants.indexWhere((p) => p.id == currentUserId);
            if (userIndex != -1) {
              userPoints = sortedParticipants[userIndex].points ?? 0;
              userRank = userIndex + 1;
            }
          }

          return BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
            listenWhen: (previous, current) =>
                current is JoinCompetitionSuccess ||
                current is LeaveCompetitionSuccess ||
                current is ViewParticipantsError,
            listener: _handleParticipantStateListeners,
            builder: (context, participantsState) {
              final isActionLoading =
                  participantsState is ViewParticipantsActionLoading;

              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: _buildAppBar(
                  context: context,
                  competition: competition,
                  isFavorite: isFavorite,
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

                    final teams = (teamsState is ViewTeamsLoaded)
                        ? teamsState.teams
                        : <TeamEntity>[];

                    final sortedTeams = List<TeamEntity>.from(teams)
                      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

                    final userCurrentTeam =
                        sortedTeams.cast<TeamEntity?>().firstWhere(
                              (t) =>
                                  t?.members.any((m) => m.id == currentUserId) ??
                                  false,
                              orElse: () => null,
                            );

                    final bool isUserInAnyTeam = userCurrentTeam != null;
                    final bool hasNoTeams = sortedTeams.isEmpty;

                    return RefreshIndicator(
                      color: AppColors.primaryPurple,
                      onRefresh: () async {
                        context
                            .read<CompetitionHomeCubit>()
                            .loadCompetitionData(
                              competition: competition,
                              userId: currentUserId,
                            );
                        context
                            .read<ViewTeamsCubit>()
                            .streamTeams(competition.id);
                        context
                            .read<ViewParticipantsCubit>()
                            .listenToParticipants(competition.id);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (competition.imageUrl != null &&
                                competition.imageUrl!.trim().isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: competition.imageUrl!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 180,
                                  color: AppColors.cardBackground,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const SizedBox.shrink(),
                              ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ─── Stat Card: User Dynamic Summary ───
                                  _UserSummaryCard(
                                    daysRemaining: displayDuration,
                                    currentDayNumber: currentDayNumber,
                                    totalDays: totalDays,
                                    progressRatio: progressRatio,
                                    userPoints: userPoints,
                                    userRank: userRank,
                                  ),
                                  const SizedBox(height: 14),

                                  // 🔗 Always-visible external group button
                                  _ExternalGroupButton(
                                    linkUrl: competition.linkUrl,
                                  ),
                                  const SizedBox(height: 16),

                                  if (!isUserInAnyTeam && !hasNoTeams) ...[
                                    _UnassignedTeamBanner(),
                                    const SizedBox(height: 20),
                                  ],

                                  if (isUserInAnyTeam) ...[
                                    const Text(
                                      'Your Team',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => _navigateToTeamMembers(
                                        context,
                                        userCurrentTeam,
                                      ),
                                      child: TeamExpansionCard(
                                        key: ValueKey(
                                          'user_team_${userCurrentTeam.id}',
                                        ),
                                        team: userCurrentTeam,
                                        rank: sortedTeams.indexOf(userCurrentTeam) +
                                            1,
                                        rankBadge: _getRankingBadge(
                                          sortedTeams.indexOf(userCurrentTeam) + 1,
                                        ),
                                        isJoined: true,
                                        hasJoinedOtherTeam: false,
                                        currentUserId: currentUserId,
                                        isCompetitionEnded: competition.isFinished,
                                        maxMembersLimit:
                                            _getCapacityLimit(userCurrentTeam),
                                        isActionPending: isActionLoading,
                                        onToggleJoin: () => _handleJoinLeave(
                                          context: context,
                                          targetTeam: userCurrentTeam,
                                          isUserInThisTeam: true,
                                          isUserInAnyTeam: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  if (hasNoTeams)
                                    _buildEmptyState()
                                  else ...[
                                    CustomTopTeamsWidget(
                                      teams: sortedTeams,
                                      competition: competition,
                                      onShowConfirmDialog: ({
                                        required context,
                                        required title,
                                        required content,
                                        required confirmText,
                                        required onConfirm,
                                        confirmColor,
                                      }) {},
                                      onViewAllPressed: () {
                                        final viewTeamsCubit =
                                            context.read<ViewTeamsCubit>();
                                        final viewParticipantsCubit = context
                                            .read<ViewParticipantsCubit>();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider.value(
                                                  value: viewTeamsCubit,
                                                ),
                                                BlocProvider.value(
                                                  value: viewParticipantsCubit,
                                                ),
                                              ],
                                              child: ViewAllTeamsScreen(
                                                competition: competition,
                                                currentUserId: currentUserId,
                                                onToggleJoin: ({
                                                  required context,
                                                  required targetTeam,
                                                  required isUserInThisTeam,
                                                  required isUserInAnyTeam,
                                                }) => _handleJoinLeave(
                                                  context: context,
                                                  targetTeam: targetTeam,
                                                  isUserInThisTeam:
                                                      isUserInThisTeam,
                                                  isUserInAnyTeam:
                                                      isUserInAnyTeam,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required CompetitionEntity competition,
    required bool isFavorite,
  }) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        competition.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.bookmark : Icons.bookmark_border,
            color: isFavorite ? Colors.amber : Colors.white70,
          ),
          onPressed: () => context.read<CompetitionHomeCubit>().toggleFavorite(
                userId: currentUserId,
                competition: competition,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white70),
          onPressed: () => _shareCompetition(context),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: AppColors.cardBackground,
          onSelected: (value) {
            if (value == 'rules') _showRulesDialog(context);
            if (value == 'report') _showReportDialog(context);
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'rules',
              child: Text(
                'Rules & Terms',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Text(
                'Report',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ],
    );
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

  void _shareCompetition(BuildContext context) {
    _showSnackBar(context, 'Share link copied to clipboard.', Colors.blueAccent);
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Rules & Terms', style: TextStyle(color: Colors.white)),
        content: Text(
          competition.description.isNotEmpty
              ? competition.description
              : 'Follow all competition guidelines and respect your teammates.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryPurple)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    _showSnackBar(context, 'Report submitted for review.', Colors.orangeAccent);
  }

  void _handleParticipantStateListeners(
    BuildContext context,
    ViewParticipantsState state,
  ) {
    if (state is ViewParticipantsError) {
      _showSnackBar(context, state.message, AppColors.privateRed);
    } else if (state is JoinCompetitionSuccess ||
        state is LeaveCompetitionSuccess) {
      final message = state is JoinCompetitionSuccess
          ? state.message
          : (state as LeaveCompetitionSuccess).message;
      _showSnackBar(context, message, AppColors.publicGreen);

      context
          .read<ViewParticipantsCubit>()
          .listenToParticipants(competition.id);
    }
  }

  Future<void> _handleJoinLeave({
    required BuildContext context,
    required TeamEntity targetTeam,
    required bool isUserInThisTeam,
    required bool isUserInAnyTeam,
  }) async {
    final viewParticipantsCubit = context.read<ViewParticipantsCubit>();

    if (isUserInThisTeam) {
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
          userId: currentUserId, // ⚡ Added required userId argument
        );
      }
      return;
    }

    if (isUserInAnyTeam) {
      _showSnackBar(
        context,
        'You must leave your current team before joining a new one.',
        Colors.orangeAccent,
      );
      return;
    }

    final capacityLimit = _getCapacityLimit(targetTeam);
    final isFull =
        capacityLimit != null && targetTeam.members.length >= capacityLimit;

    if (isFull) {
      _showSnackBar(
        context,
        'This team has reached its maximum member limit.',
        Colors.orangeAccent,
      );
      return;
    }

    String? joinCode;
    if (targetTeam.isPrivate) {
      joinCode = await _showJoinCodeDialog(context, targetTeam.name);
      if (joinCode == null || joinCode.trim().isEmpty) return;
    }

    if (!context.mounted) return;

    viewParticipantsCubit.joinTeam(
      competitionId: competition.id,
      teamId: targetTeam.id,
      userId: currentUserId, // ⚡ Added required userId argument
      joinCode: joinCode?.trim(),
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

  void _showSnackBar(BuildContext context, String text, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _getRankingBadge(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 18));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 18));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 18));
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
    }
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

// --- Component: External Link Button ---

class _ExternalGroupButton extends StatelessWidget {
  final String? linkUrl;

  const _ExternalGroupButton({this.linkUrl});

  void _handleClick(BuildContext context) async {
    if (linkUrl == null || linkUrl!.trim().isEmpty) {
      _showNoLinkDialog(context);
      return;
    }

    final Uri uri = Uri.parse(linkUrl!.trim());
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showNoLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderOutline),
        ),
        title: const Text(
          'No Link Available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          'There is no external group or video link provided for this competition.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: () => _handleClick(context),
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new, color: Color(0xFFFFC107), size: 20),
              SizedBox(width: 10),
              Text(
                'Join Group / View Media Link',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Component: Dynamic User Summary Card ---

class _UserSummaryCard extends StatelessWidget {
  final int daysRemaining;
  final int currentDayNumber;
  final int totalDays;
  final double progressRatio;
  final int userPoints;
  final int userRank;

  const _UserSummaryCard({
    required this.daysRemaining,
    required this.currentDayNumber,
    required this.totalDays,
    required this.progressRatio,
    required this.userPoints,
    required this.userRank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFFFFC107), size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$daysRemaining Days Left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Day $currentDayNumber of $totalDays',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryPurple),
                ),
                child: Column(
                  children: [
                    Text(
                      '$userPoints pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      userRank > 0 ? 'Rank #$userRank' : 'Unranked',
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: Colors.white10,
              color: const Color(0xFFFFC107),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Component: Unassigned Team Banner ---

class _UnassignedTeamBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are not in a team yet. Select a team below to participate!',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dialog Helpers ---

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

Future<String?> _showJoinCodeDialog(BuildContext context, String teamName) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _JoinCodeDialog(teamName: teamName),
  );
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