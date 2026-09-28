import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_state.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_participants_view_all.dart';
import 'package:ptook/features/view_competition/presintation/widgets/report_dialog.dart';

class CompetitionIndividualHomeView extends StatefulWidget {
  final CompetitionEntity competition;
  final String currentUserId;

  const CompetitionIndividualHomeView({
    super.key,
    required this.competition,
    required this.currentUserId,
  });

  @override
  State<CompetitionIndividualHomeView> createState() =>
      _CompetitionIndividualHomeViewState();
}

class _CompetitionIndividualHomeViewState
    extends State<CompetitionIndividualHomeView> {
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CompetitionHomeCubit>().loadCompetitionData(
          competition: widget.competition,
          userId: widget.currentUserId,
        );
  }

  void _toggleFavorite(CompetitionEntity currentCompetition) {
    context.read<CompetitionHomeCubit>().toggleFavorite(
          userId: widget.currentUserId,
          competition: currentCompetition,
        );
  }

  void _handleLeave() {
    if (_isLeaving) return;

    setState(() {
      _isLeaving = true;
    });

    context.read<ViewParticipantsCubit>().leaveIndividualCompetition(
          competitionId: widget.competition.id,
          userId: widget.currentUserId,
        );
  }

  void _shareCompetition() {
    final shareUrl =
        'https://yourapp.com/competitions/${widget.competition.id}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    _showSnackBar('Link copied to clipboard!', Colors.green);
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Row(
          children: [
            Icon(Icons.gavel_outlined, color: AppColors.primaryAccent),
            SizedBox(width: 8),
            Text(
              'Rules & Terms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            widget.competition.description.isNotEmpty
                ? widget.competition.description
                : '1. Play fairly and respect other participants.\n'
                    '2. Submissions after the deadline will not be counted.\n'
                    '3. Points are granted based on verified activity.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveCompetition() {
    if (_isLeaving) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Leave Competition',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to leave this competition? Your current rank and accumulated points will be removed.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).clearSnackBars();
              _handleLeave();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Leave',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ReportDialog(
        onSubmit: (reason) {
          _showSnackBar('Report submitted successfully.', Colors.green);
        },
      ),
    );
  }

  void _navigateToParticipants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ViewParticipantsCubit>(),
          child: CompetitionParticipantsViewAll(
            competitionId: widget.competition.id,
            currentUserId: widget.currentUserId,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    CompetitionEntity competition,
    bool isFavorite,
  ) {
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
          onPressed: () => _toggleFavorite(competition),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white70),
          onPressed: _shareCompetition,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: AppColors.cardBackground,
          onSelected: (value) {
            if (value == 'rules') _showRulesDialog();
            if (value == 'report') _showReportDialog();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rules',
              child: Text('Rules & Terms', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Text('Report', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompetitionHomeCubit, CompetitionHomeState>(
          listener: (context, state) {
            if (state is CompetitionHomeActionSuccess) {
              _showSnackBar(state.message, Colors.green);
            } else if (state is CompetitionHomeError) {
              _showSnackBar(state.message, Colors.redAccent);
            }
          },
        ),
        BlocListener<ViewParticipantsCubit, ViewParticipantsState>(
          listener: (context, state) {
            if (state is LeaveCompetitionSuccess) {
              _showSnackBar(state.message, AppColors.cardBackground);
              Navigator.pop(context, true);
            } else if (state is ViewParticipantsError) {
              if (mounted) {
                setState(() {
                  _isLeaving = false;
                });
              }
              _showSnackBar(state.message, Colors.redAccent);
            }
          },
        ),
      ],
      child: BlocBuilder<CompetitionHomeCubit, CompetitionHomeState>(
        builder: (context, state) {
          if (state is CompetitionHomeLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryAccent),
              ),
            );
          }

          if (state is CompetitionHomeLoaded) {
            final competition = state.competition;
            final participants = state.participants;
            final isFavorite = state.isFavorite;

            final sortedParticipants = List<ParticipantEntity>.from(participants)
              ..sort((a, b) => b.points.compareTo(a.points));

            final userIndex = sortedParticipants
                .indexWhere((p) => p.userId == widget.currentUserId);
            final isJoined = userIndex != -1;
            final userRank = isJoined ? '#${userIndex + 1}' : 'N/A';
            final userPoints =
                isJoined ? sortedParticipants[userIndex].points : 0;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(competition, isFavorite),
              body: RefreshIndicator(
                onRefresh: () async => context
                    .read<CompetitionHomeCubit>()
                    .fetchCompetitionDetails(
                      competitionId: widget.competition.id,
                      userId: widget.currentUserId,
                    ),
                color: AppColors.primaryAccent,
                backgroundColor: AppColors.cardBackground,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroHeaderCard(competition: competition),
                      const SizedBox(height: 16),
                      _QuickStatsRow(
                        participantCount: participants.length,
                        maxCapacity: competition.maxParticipants ?? 100,
                        userRank: userRank,
                        userPoints: userPoints,
                      ),
                      const SizedBox(height: 16),
                      _LeaderboardCard(
                        topParticipants:
                            sortedParticipants.take(3).toList(),
                        onViewFullRanking: _navigateToParticipants,
                      ),
                      const SizedBox(height: 24),
                      _ActionButtonsGroup(
                        isLoading: state.isActionLoading || _isLeaving,
                        onLeavePressed: _confirmLeaveCompetition,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Failed to load competition details.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroHeaderCard extends StatelessWidget {
  final CompetitionEntity competition;

  const _HeroHeaderCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  competition.type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            competition.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (competition.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              competition.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final int participantCount;
  final int maxCapacity;
  final String userRank;
  final int userPoints;

  const _QuickStatsRow({
    required this.participantCount,
    required this.maxCapacity,
    required this.userRank,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            title: 'Rank',
            value: userRank,
            icon: Icons.leaderboard,
            iconColor: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            title: 'Points',
            value: '$userPoints',
            icon: Icons.stars,
            iconColor: AppColors.primaryAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            title: 'Joined',
            value: '$participantCount/$maxCapacity',
            icon: Icons.group,
            iconColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final List<ParticipantEntity> topParticipants;
  final VoidCallback onViewFullRanking;

  const _LeaderboardCard({
    required this.topParticipants,
    required this.onViewFullRanking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Performers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: onViewFullRanking,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topParticipants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No participants yet.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            Column(
              children: List.generate(topParticipants.length, (index) {
                final participant = topParticipants[index];
                final hasAvatar = participant.avatarUrl != null && participant.avatarUrl!.trim().isNotEmpty;
                final fallbackInitial = participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      // 1️⃣ Cached Avatar Image with Fallback Initial
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.15),
                        backgroundImage: hasAvatar
                            ? CachedNetworkImageProvider(participant.avatarUrl!)
                            : null,
                        child: !hasAvatar
                            ? Text(
                                fallbackInitial,
                                style: const TextStyle(
                                  color: AppColors.primaryAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // 2️⃣ Name
                      Expanded(
                        child: Text(
                          participant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // 3️⃣ Points
                      Text(
                        '${participant.points} pts',
                        style: const TextStyle(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )
        ],
      ),
    );
  }
}

class _ActionButtonsGroup extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLeavePressed;

  const _ActionButtonsGroup({
    required this.isLoading,
    required this.onLeavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onLeavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.redAccent,
                ),
              )
            : const Text(
                'Leave Competition',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}