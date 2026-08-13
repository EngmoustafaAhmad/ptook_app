import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/views/competition_participants_view.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart';

// Key Theme Colors
abstract class _AppColors {
  static const background = Color(0xFF0F111A);
  static const cardBackground = Color(0xFF1B1E2B);
  static const primaryAccent = Color(0xFF9D61FF);
  static const secondaryGradient = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
}

class CompetitionHomeView extends StatefulWidget {
  final CompetitionEntity competition;
  final String currentUserId;

  const CompetitionHomeView({
    super.key,
    required this.competition,
    required this.currentUserId, required String competitionId,
  });

  @override
  State<CompetitionHomeView> createState() => _CompetitionHomeViewState();
}

class _CompetitionHomeViewState extends State<CompetitionHomeView> {
  bool _isFavorite = false;
  List<ParticipantEntity> _participants = [];

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  void _fetchParticipants() {
    context.read<ParticipantCubit>().fetchParticipants(widget.competition.id);
  }
void _shareCompetition() {
    final shareUrl = 'https://yourapp.com/competitions/${widget.competition.id}';
    Clipboard.setData(ClipboardData(text: shareUrl));

    _showSnackBar(context, 'Link copied to clipboard!', Colors.green);
  }

  /// 2. Show Rules & Terms Dialog
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
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: _AppColors.primaryAccent)),
          ),
        ],
      ),
    );
  }

  /// 3. Show Report Dialog with input
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _AppColors.primaryAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              _showSnackBar(context, 'Report submitted successfully.', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
      body: BlocConsumer<ParticipantCubit, ParticipantState>(
        listener: (context, state) {
          if (state is JoinCompetitionSuccess) {
            _showSnackBar(context, state.message, Colors.green);
          } else if (state is LeaveCompetitionSuccess) {
            _showSnackBar(context, state.message, Colors.orangeAccent);
          } else if (state is ParticipantError) {
            _showSnackBar(context, state.message, Colors.redAccent);
          }
        },
        builder: (context, state) {
          // Maintain participant cache across action states to prevent UI flickering
          if (state is ParticipantLoaded) {
            _participants = state.participants;
          }

          if (state is ParticipantLoading && _participants.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _AppColors.primaryAccent),
            );
          }

          // Pre-calculate ranked list once for stats & subviews
          final sortedParticipants = List<ParticipantEntity>.from(_participants)
            ..sort((a, b) => b.points.compareTo(a.points));

          final userIndex = sortedParticipants
              .indexWhere((p) => p.userId == widget.currentUserId);
          final isJoined = userIndex != -1;
          final userRank = isJoined ? '#${userIndex + 1}' : 'N/A';
          final userPoints = isJoined ? sortedParticipants[userIndex].points : 0;

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
                  // 1. Hero Header Banner
                  _HeroHeaderCard(competition: widget.competition),
                  const SizedBox(height: 16),

                  // 2. Quick Stats Row
                  _QuickStatsRow(
                    participantCount: _participants.length,
                    maxCapacity: widget.competition.maxParticipants ?? 100,
                    userRank: userRank,
                    userPoints: userPoints,
                  ),
                  const SizedBox(height: 16),

                  // 3. Leaderboard Preview Section
                  _LeaderboardCard(
                    topParticipants: sortedParticipants.take(3).toList(),
                    onViewFullRanking: () => _navigateToParticipants(context),
                  ),
                  const SizedBox(height: 16),

                  // 4. Participants Avatar Preview Section
                  _ParticipantsPreviewCard(
                    participants: sortedParticipants,
                    onViewAll: () => _navigateToParticipants(context),
                  ),
                  const SizedBox(height: 24),

                  // 5. Dynamic Action Buttons Group
                  _ActionButtonsGroup(
                    isJoined: isJoined,
                    isFavorite: _isFavorite,
                    isLoading: state is ParticipantActionLoading,
                    onFavoriteToggle: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                    onJoinLeavePressed: () =>
                        _handleJoinLeave(isJoined: isJoined),
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

  void _handleJoinLeave({required bool isJoined}) {
    final cubit = context.read<ParticipantCubit>();
    if (isJoined) {
      cubit.leaveCompetition(
        competitionId: widget.competition.id,
        userId: widget.currentUserId,
      );
    } else {
      cubit.joinCompetition(
        competitionId: widget.competition.id,
        userId: widget.currentUserId,
      );
    }
  }

  void _navigateToParticipants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ParticipantCubit>(),
          child: CompetitionParticipantsView(
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

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

/// 1. Hero Header Banner
class _HeroHeaderCard extends StatelessWidget {
  final CompetitionEntity competition;

  const _HeroHeaderCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          colors: [Color(0xFF261843), Color(0xFF141322)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Tag Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: screenWidth * 0.55,
                child: Text(
                  competition.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                  SizedBox(width: 6),
                  Text('Ends in', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                '05d 12h 30m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            top: -10,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 120,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Quick Stats Row (Participants, Rank, Points)
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
    final progressValue =
        maxCapacity > 0 ? (participantCount / maxCapacity).clamp(0.0, 1.0) : 0.0;

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
            children: [
              _StatItem(
                icon: Icons.people_alt_rounded,
                iconColor: _AppColors.primaryAccent,
                label: 'Participants',
                valueSpan: TextSpan(
                  children: [
                    TextSpan(
                      text: '$participantCount ',
                      style: const TextStyle(
                        color: _AppColors.primaryAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '/ $maxCapacity',
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _StatItem(
                icon: Icons.leaderboard_rounded,
                iconColor: Colors.greenAccent,
                label: 'Your Rank',
                valueText: userRank,
                valueColor: Colors.greenAccent,
              ),
              _StatItem(
                icon: Icons.stars_rounded,
                iconColor: Colors.amber,
                label: 'Your Points',
                valueText: '$userPoints',
                valueColor: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white10,
              color: _AppColors.primaryAccent,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? valueText;
  final InlineSpan? valueSpan;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.valueText,
    this.valueSpan,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 2),
                if (valueSpan != null)
                  RichText(text: valueSpan!, maxLines: 1)
                else
                  Text(
                    valueText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Leaderboard Preview Card (Top 3)
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
              const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topParticipants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'No participants registered yet.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topParticipants.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
              itemBuilder: (context, index) {
                return _LeaderboardRowItem(
                  rank: index + 1,
                  participant: topParticipants[index],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LeaderboardRowItem extends StatelessWidget {
  final int rank;
  final ParticipantEntity participant;

  const _LeaderboardRowItem({required this.rank, required this.participant});

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : const Color(0xFFCD7F32);

    final hasAvatar =
        participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: rankColor.withValues(alpha: 0.2),
          child: Text(
            '$rank',
            style: TextStyle(
              color: rankColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white10,
          backgroundImage: hasAvatar ? NetworkImage(participant.avatarUrl!) : null,
          child: !hasAvatar
              ? Text(
                  participant.initials,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            participant.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${participant.points} pts',
          style: TextStyle(
            color: rank == 1 ? Colors.amber : Colors.amber.shade200,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// 4. Participants Horizontal Preview Card
class _ParticipantsPreviewCard extends StatelessWidget {
  final List<ParticipantEntity> participants;
  final VoidCallback onViewAll;

  const _ParticipantsPreviewCard({
    required this.participants,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final previewList = participants.take(4).toList();
    final remainingCount =
        participants.length > 4 ? participants.length - 4 : 0;

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
              const Row(
                children: [
                  Icon(Icons.groups_outlined, color: _AppColors.primaryAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Participants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: _AppColors.primaryAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: _AppColors.primaryAccent, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (participants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No participants yet', style: TextStyle(color: Colors.white38)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...previewList.map((p) => _ParticipantAvatarItem(participant: p)),
                if (remainingCount > 0)
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF2B2240),
                        child: Text(
                          '+$remainingCount',
                          style: const TextStyle(
                            color: _AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('More', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ParticipantAvatarItem extends StatelessWidget {
  final ParticipantEntity participant;

  const _ParticipantAvatarItem({required this.participant});

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white10,
              backgroundImage: hasAvatar ? NetworkImage(participant.avatarUrl!) : null,
              child: !hasAvatar
                  ? Text(
                      participant.initials,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _AppColors.cardBackground, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          participant.name.split(' ').first,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

/// 5. Dynamic Action Buttons Group
class _ActionButtonsGroup extends StatelessWidget {
  final bool isJoined;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onJoinLeavePressed;

  const _ActionButtonsGroup({
    required this.isJoined,
    required this.isFavorite,
    required this.isLoading,
    required this.onFavoriteToggle,
    required this.onJoinLeavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Action Button (Join / Leave)
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isJoined
                ? null
                : const LinearGradient(colors: _AppColors.secondaryGradient),
            color: isJoined ? Colors.redAccent.withValues(alpha: 0.15) : null,
            border: isJoined
                ? Border.all(color: Colors.redAccent.withValues(alpha: 0.5))
                : null,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onJoinLeavePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isJoined ? Icons.logout : Icons.login,
                        color: isJoined ? Colors.redAccent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isJoined ? 'Leave Competition' : 'Join Competition',
                        style: TextStyle(
                          color: isJoined ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Action Button (Favorite toggle)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onFavoriteToggle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : Colors.white70,
            ),
            label: Text(
              isFavorite ? 'Remove From Favorites' : 'Add To Favorites',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}