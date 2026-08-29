import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_participants_view_all.dart';

abstract class _AppColors {
  static const background = Color(0xFF0F111A);
  static const cardBackground = Color(0xFF1B1E2B);
  static const primaryAccent = Color(0xFF9D61FF);
  static const secondaryGradient = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
}

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
  bool _isFavorite = false;
  List<ParticipantEntity> _participants = [];

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  void _fetchParticipants() {
    context
        .read<ViewParticipantsCubit>()
        .listenToParticipants(widget.competition.id);
  }

  void _shareCompetition() {
    final shareUrl =
        'https://yourapp.com/competitions/${widget.competition.id}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    _showSnackBar(context, 'Link copied to clipboard!', Colors.green);
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Row(
          children: [
            Icon(Icons.gavel_outlined, color: _AppColors.primaryAccent),
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
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: _AppColors.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Report Competition',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please describe why you are reporting this competition:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Inappropriate content, spam, etc.',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: _AppColors.primaryAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              _showSnackBar(
                  context, 'Report submitted successfully.', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
        listener: (context, state) {
          // 👈 FIX: Move state caching inside the listener
          if (state is ViewParticipantsLoaded) {
            setState(() {
              _participants = state.participants;
            });
          } else if (state is JoinCompetitionSuccess) {
            _showSnackBar(context, state.message, Colors.green);
          } else if (state is LeaveCompetitionSuccess) {
            _showSnackBar(context, state.message, Colors.orangeAccent);
          } else if (state is ViewParticipantsError) {
            _showSnackBar(context, state.message, Colors.redAccent);
          }
        },
        builder: (context, state) {
          if (state is ViewParticipantsLoading && _participants.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _AppColors.primaryAccent),
            );
          }

          final sortedParticipants = List<ParticipantEntity>.from(_participants)
            ..sort((a, b) => b.points.compareTo(a.points));

          final userIndex = sortedParticipants
              .indexWhere((p) => p.userId == widget.currentUserId);
          final isJoined = userIndex != -1;
          final userRank = isJoined ? '#${userIndex + 1}' : 'N/A';
          final userPoints =
              isJoined ? sortedParticipants[userIndex].points : 0;

          return RefreshIndicator(
            onRefresh: () async => _fetchParticipants(),
            color: _AppColors.primaryAccent,
            backgroundColor: _AppColors.cardBackground,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroHeaderCard(competition: widget.competition),
                  const SizedBox(height: 16),
                  _QuickStatsRow(
                    participantCount: _participants.length,
                    maxCapacity: widget.competition.maxParticipants ?? 100,
                    userRank: userRank,
                    userPoints: userPoints,
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardCard(
                    topParticipants: sortedParticipants.take(3).toList(),
                    onViewFullRanking: () => _navigateToParticipants(context),
                  ),
                  const SizedBox(height: 24),
                  _ActionButtonsGroup(
                    isFavorite: _isFavorite,
                    isLoading: state is ViewParticipantsActionLoading,
                    onFavoriteToggle: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                    onLeavePressed: () => _handleLeave(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        widget.competition.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.white70,
          ),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          color: _AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          onSelected: (String value) {
            switch (value) {
              case 'share':
                _shareCompetition();
                break;
              case 'rules':
                _showRulesDialog();
                break;
              case 'report':
                _showReportDialog();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text('Share Competition', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'rules',
              child: Row(
                children: [
                  Icon(Icons.gavel_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 10),
                  Text('Rules & Terms', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.redAccent, size: 18),
                  SizedBox(width: 10),
                  Text('Report', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleLeave() {
    context.read<ViewParticipantsCubit>().leaveCompetition(
          competitionId: widget.competition.id,
          userId: widget.currentUserId,
        );
  }

  void _navigateToParticipants(BuildContext context) {
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

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          colors: _AppColors.secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primaryAccent.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            iconColor: _AppColors.primaryAccent,
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
        color: _AppColors.cardBackground,
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
        color: _AppColors.cardBackground,
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
                    color: _AppColors.primaryAccent,
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: index == 0
                            ? Colors.amber
                            : index == 1
                                ? Colors.grey
                                : Colors.brown,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          participant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${participant.points} pts',
                        style: const TextStyle(
                          color: _AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}


class _ActionButtonsGroup extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLeavePressed;

  const _ActionButtonsGroup({
    required this.isFavorite,
    required this.isLoading,
    required this.onFavoriteToggle,
    required this.onLeavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
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
        ),
      ],
    );
  }
}