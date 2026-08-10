import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/views/manage_competition_view.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

class CompetitionHomeView extends StatefulWidget {
  final CompetitionEntity competition;

  const CompetitionHomeView({
    super.key,
    required this.competition,
  });

  @override
  State<CompetitionHomeView> createState() => _CompetitionHomeViewState();
}

class _CompetitionHomeViewState extends State<CompetitionHomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isOwner =>
      _currentUserId != null && _currentUserId == widget.competition.ownerId;

  bool get _isTeamCompetition => widget.competition.type == "team";

  bool get _isParticipant =>
      _currentUserId != null &&
      (widget.competition.participantIds.contains(_currentUserId));

  Future<void> _onRefresh() async {
    // TODO: Refresh leaderboard data via Cubit/Bloc
    await Future.delayed(const Duration(seconds: 1));
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? "Saved to favorites!" : "Removed from favorites"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLeaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Leave Competition?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure? Leaving will reset your points and rank on this leaderboard.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // 1. Close alert dialog
          
              // 2. Dispatch leave event to backend / state management
              // Replace with your actual Cubit/Bloc method name:
              await context.read<CompetitionCubit>().leaveCompetition(widget.competition.id);
          
              if (context.mounted) {
                // 3. Return 'true' to indicate a state change to the previous screen
                Navigator.pop(context, true); 
              }
            },
            child: const Text("Leave", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCompetitionView(competition: widget.competition),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ParticipantEntity> participants = 
    widget.competition.participants?.cast<ParticipantEntity>() ?? [];

    // 1. Sort participants by points descending
    final sortedList = List<ParticipantEntity>.from(participants)
      ..sort((a, b) => b.points.compareTo(a.points));

    // 2. Find Current User Stats using `userId`
    final userIndex = sortedList.indexWhere((p) => p.userId == _currentUserId);
    final currentUser = userIndex != -1 ? sortedList[userIndex] : null;
    final userRank = userIndex != -1 ? userIndex + 1 : null;
    final userPoints = currentUser?.points ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.competition.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: _isFavorite ? AppColors.primary : Colors.white70,
            ),
            onPressed: _toggleFavorite,
          ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.primary),
              onPressed: () => _navigateToManage(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        12.vs,

                        // Hero Header Tile
                        _StandingHeroCard(
                          isOwner: _isOwner,
                          userRank: userRank,
                          userPoints: userPoints,
                          totalStars: currentUser?.totalStarsEarned ?? 0,
                          totalParticipants: sortedList.length,
                          endDate: widget.competition.endDate,
                        ),
                        16.vs,

                        // Gamified Level / Progress Bar
                        _GamifiedProgressBar(
                          userPoints: userPoints,
                          totalStars: currentUser?.totalStarsEarned ?? 0,
                        ),
                        24.vs,

                        // Dynamic Top 3 Podium Standings
                        if (sortedList.isNotEmpty) ...[
                          _PodiumView(sortedList: sortedList),
                          24.vs,
                        ],
                      ],
                    ),
                  ),
                ),

                // Sticky Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white.withOpacity(0.5),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      tabs: [
                        Tab(
                          text: _isTeamCompetition
                              ? "Team Standings"
                              : "Leaderboard",
                        ),
                        const Tab(text: "Rules & Overview"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: RANKED LEADERBOARD LIST
                _LeaderboardListView(
                  sortedList: sortedList,
                  currentUserId: _currentUserId,
                  isTeamType: _isTeamCompetition,
                ),

                // TAB 2: RULES & OVERVIEW
                _RulesAndOverviewTab(
                  competition: widget.competition,
                  isOwner: _isOwner,
                  isParticipant: _isParticipant,
                  onManageTap: () => _navigateToManage(context),
                  onLeaveTap: _showLeaveConfirmationDialog,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HERO STANDING CARD
// =============================================================================
class _StandingHeroCard extends StatelessWidget {
  final bool isOwner;
  final int? userRank;
  final int userPoints;
  final int totalStars;
  final int totalParticipants;
  final DateTime endDate;

  const _StandingHeroCard({
    required this.isOwner,
    required this.userRank,
    required this.userPoints,
    required this.totalStars,
    required this.totalParticipants,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatTile(
                label: isOwner ? "Players" : "Your Rank",
                value: isOwner
                    ? "$totalParticipants"
                    : (userRank != null ? "#$userRank" : "--"),
                subtext: isOwner ? "joined" : "of $totalParticipants",
                accentColor: AppColors.primary,
                icon: Icons.leaderboard,
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _StatTile(
                label: "Points",
                value: "$userPoints",
                subtext: "pts",
                accentColor: Colors.amberAccent,
                icon: Icons.stars,
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _StatTile(
                label: "Total Stars",
                value: "$totalStars ⭐",
                subtext: "all time",
                accentColor: Colors.orangeAccent,
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color accentColor;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.subtext,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accentColor),
            4.hs,
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        6.vs,
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        2.vs,
        Text(
          subtext,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// GAMIFIED XP & STARS PROGRESS BAR
// =============================================================================
class _GamifiedProgressBar extends StatelessWidget {
  final int userPoints;
  final int totalStars;

  const _GamifiedProgressBar({
    required this.userPoints,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    const nextLevelTarget = 500;
    final progress = (userPoints / nextLevelTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech,
                      color: Colors.amberAccent, size: 18),
                  6.hs,
                  const Text(
                    "Next Tier Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                "$userPoints / $nextLevelTarget XP",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          8.vs,
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TOP 3 PODIUM VIEW
// =============================================================================
class _PodiumView extends StatelessWidget {
  final List<ParticipantEntity> sortedList;

  const _PodiumView({required this.sortedList});

  @override
  Widget build(BuildContext context) {
    final first = sortedList.isNotEmpty ? sortedList[0] : null;
    final second = sortedList.length > 1 ? sortedList[1] : null;
    final third = sortedList.length > 2 ? sortedList[2] : null;

    if (first == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2ND PLACE (SILVER)
        if (second != null)
          _PodiumColumn(
            participant: second,
            rank: 2,
            height: 90,
            color: const Color(0xFFC0C0C0),
          )
        else
          const SizedBox(width: 80),

        12.hs,

        // 1ST PLACE (GOLD)
        _PodiumColumn(
          participant: first,
          rank: 1,
          height: 120,
          color: const Color(0xFFFFD700),
        ),

        12.hs,

        // 3RD PLACE (BRONZE)
        if (third != null)
          _PodiumColumn(
            participant: third,
            rank: 3,
            height: 70,
            color: const Color(0xFFCD7F32),
          )
        else
          const SizedBox(width: 80),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final ParticipantEntity participant;
  final int rank;
  final double height;
  final Color color;

  const _PodiumColumn({
    required this.participant,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = participant.name.isNotEmpty ? participant.name : 'Participant';
    final hasAvatar = participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              backgroundImage: hasAvatar ? NetworkImage(participant.avatarUrl!) : null,
              child: !hasAvatar
                  ? Text(
                      participant.initials,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$rank",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        6.vs,
        SizedBox(
          width: 80,
          child: Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        2.vs,
        Text(
          "${participant.points} pts",
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.vs,
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: color, size: 24),
              if (participant.currentCompetitionStars > 0) ...[
                2.vs,
                Text(
                  "+${participant.currentCompetitionStars} ⭐",
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 1: LEADERBOARD LIST VIEW
// =============================================================================
class _LeaderboardListView extends StatelessWidget {
  final List<ParticipantEntity> sortedList;
  final String? currentUserId;
  final bool isTeamType;

  const _LeaderboardListView({
    required this.sortedList,
    required this.currentUserId,
    required this.isTeamType,
  });

  int _calculateRank(int index) {
    if (index == 0) return 1;
    final currentPoints = sortedList[index].points;
    final previousPoints = sortedList[index - 1].points;

    if (currentPoints == previousPoints) {
      return _calculateRank(index - 1);
    }
    return index + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (sortedList.isEmpty) {
      return Center(
        child: Text(
          isTeamType ? "No teams joined yet" : "No participants joined yet",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => 8.vs,
      itemBuilder: (context, index) {
        final participant = sortedList[index];
        final isCurrentUser = participant.userId == currentUserId;
        final rank = _calculateRank(index);

        Color rankColor;
        switch (rank) {
          case 1:
            rankColor = const Color(0xFFFFD700);
            break;
          case 2:
            rankColor = const Color(0xFFC0C0C0);
            break;
          case 3:
            rankColor = const Color(0xFFCD7F32);
            break;
          default:
            rankColor = Colors.white54;
        }

        final displayName = participant.name.isNotEmpty ? participant.name : 'Participant';
        final hasAvatar = participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withOpacity(0.18)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrentUser
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.06),
              width: isCurrentUser ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  "#$rank",
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: hasAvatar ? NetworkImage(participant.avatarUrl!) : null,
                child: !hasAvatar
                    ? (isTeamType
                        ? const Icon(Icons.groups, size: 18, color: Colors.white70)
                        : Text(
                            participant.initials,
                            style: TextStyle(
                              color: isCurrentUser ? AppColors.primary : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                    : null,
              ),
              12.hs,
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      6.hs,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "YOU",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${participant.points} pts",
                    style: TextStyle(
                      color: isCurrentUser ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (participant.totalStarsEarned > 0)
                    Text(
                      "${participant.totalStarsEarned} ⭐",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// TAB 2: RULES & OVERVIEW
// =============================================================================
class _RulesAndOverviewTab extends StatelessWidget {
  final CompetitionEntity competition;
  final bool isOwner;
  final bool isParticipant;
  final VoidCallback onManageTap;
  final VoidCallback onLeaveTap;

  const _RulesAndOverviewTab({
    required this.competition,
    required this.isOwner,
    required this.isParticipant,
    required this.onManageTap,
    required this.onLeaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwner) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primary),
                  12.hs,
                  const Expanded(
                    child: Text(
                      "Manage points & settings",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: onManageTap,
                    child: const Text("Manage"),
                  ),
                ],
              ),
            ),
            20.vs,
          ],

          const Text(
            "Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          8.vs,
          Text(
            competition.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          24.vs,

          if (!isOwner && isParticipant) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onLeaveTap,
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: const Text(
                  "Leave Competition",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// SLIVER TAB DELEGATE
// =============================================================================
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}