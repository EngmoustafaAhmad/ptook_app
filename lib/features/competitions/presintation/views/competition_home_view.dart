import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/views/manage_competition_view.dart';

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

  Future<void> _onRefresh() async {
    // TODO: Trigger Cubit/Bloc event to refresh competition state
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCompetitionView(
          competition: widget.competition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.competition.participants ?? [];
    
    // Sort items by points descending
    final sortedList = List.from(participants)
      ..sort((a, b) => (b.points ?? 0).compareTo(a.points ?? 0));

    final userIndex = sortedList.indexWhere((p) => p.id == _currentUserId);
    final userRank = userIndex != -1 ? userIndex + 1 : null;
    final userPoints = userIndex != -1 ? sortedList[userIndex].points ?? 0 : 0;

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
          // Owner Settings Button -> Navigate to ManageCompetitionView
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.primary),
              tooltip: "Manage Competition",
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
                        // Standing summary card (Custom tailored for Owner vs Participant)
                        _StandingHeroCard(
                          isOwner: _isOwner,
                          userRank: userRank,
                          userPoints: userPoints,
                          totalParticipants: sortedList.length,
                          isTeamType: _isTeamCompetition,
                          endDate: widget.competition.endDate,
                        ),
                        20.vs,

                        // Podium (Top 3)
                        if (sortedList.length >= 3) ...[
                          _PodiumView(
                            first: sortedList[0],
                            second: sortedList[1],
                            third: sortedList[2],
                          ),
                          24.vs,
                        ],
                      ],
                    ),
                  ),
                ),
                // Persistent Tab Header
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
                              ? "Team Leaderboard"
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
                // TAB 1: LEADERBOARD
                _LeaderboardListView(
                  sortedList: sortedList,
                  currentUserId: _currentUserId,
                  isTeamType: _isTeamCompetition,
                  isOwner: _isOwner,
                ),

                // TAB 2: RULES & OVERVIEW
                _RulesAndOverviewTab(
                  competition: widget.competition,
                  isOwner: _isOwner,
                  onManageTap: () => _navigateToManage(context),
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
// HERO STANDING / STATS CARD
// =============================================================================
class _StandingHeroCard extends StatelessWidget {
  final bool isOwner;
  final int? userRank;
  final int userPoints;
  final int totalParticipants;
  final bool isTeamType;
  final DateTime endDate;

  const _StandingHeroCard({
    required this.isOwner,
    required this.userRank,
    required this.userPoints,
    required this.totalParticipants,
    required this.isTeamType,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = endDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          if (isOwner) ...[
            // Owner Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: AppColors.primary, size: 18),
                6.hs,
                const Text(
                  "Owner Control Active",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            12.vs,
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatTile(
                label: isOwner
                    ? (isTeamType ? "Total Teams" : "Participants")
                    : "Your Rank",
                value: isOwner
                    ? "$totalParticipants"
                    : (userRank != null ? "#$userRank" : "--"),
                subtext: isOwner ? "registered" : "of $totalParticipants",
                accentColor: AppColors.primary,
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _StatTile(
                label: isOwner ? "Type" : "Your Points",
                value: isOwner
                    ? (isTeamType ? "Team" : "Solo")
                    : "$userPoints",
                subtext: isOwner ? "competition" : "pts",
                accentColor: Colors.greenAccent,
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _StatTile(
                label: "Time Left",
                value: daysRemaining > 0 ? "${daysRemaining}d" : "Ended",
                subtext: "remaining",
                accentColor: Colors.orangeAccent,
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

  const _StatTile({
    required this.label,
    required this.value,
    required this.subtext,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        6.vs,
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 20,
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
// PODIUM WIDGET (TOP 3)
// =============================================================================
class _PodiumView extends StatelessWidget {
  final dynamic first;
  final dynamic second;
  final dynamic third;

  const _PodiumView({
    required this.first,
    required this.second,
    required this.third,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PodiumColumn(
          name: second.name ?? "2nd Place",
          points: second.points ?? 0,
          rank: 2,
          height: 85,
          color: const Color(0xFFC0C0C0),
        ),
        12.hs,
        _PodiumColumn(
          name: first.name ?? "1st Place",
          points: first.points ?? 0,
          rank: 1,
          height: 115,
          color: const Color(0xFFFFD700),
        ),
        12.hs,
        _PodiumColumn(
          name: third.name ?? "3rd Place",
          points: third.points ?? 0,
          rank: 3,
          height: 65,
          color: const Color(0xFFCD7F32),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final String name;
  final int points;
  final int rank;
  final double height;
  final Color color;

  const _PodiumColumn({
    required this.name,
    required this.points,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            "$rank",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        6.vs,
        SizedBox(
          width: 80,
          child: Text(
            name,
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
        4.vs,
        Text(
          "$points pts",
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.vs,
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Center(
            child: Icon(Icons.emoji_events, color: color, size: 26),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 1: LEADERBOARD LIST
// =============================================================================
class _LeaderboardListView extends StatelessWidget {
  final List<dynamic> sortedList;
  final String? currentUserId;
  final bool isTeamType;
  final bool isOwner;

  const _LeaderboardListView({
    required this.sortedList,
    required this.currentUserId,
    required this.isTeamType,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedList.isEmpty) {
      return Center(
        child: Text(
          isTeamType ? "No teams joined yet." : "No participants joined yet.",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => 10.vs,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final isCurrentUser = item.id == currentUserId;
        final rank = index + 1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: isCurrentUser
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  "#$rank",
                  style: TextStyle(
                    color: rank <= 3 ? AppColors.primary : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              10.hs,

              // Type Icon
              Icon(
                isTeamType ? Icons.groups_outlined : Icons.person_outline,
                size: 20,
                color: Colors.white.withOpacity(0.6),
              ),
              10.hs,

              // Name
              Expanded(
                child: Text(
                  item.name ??
                      (isTeamType
                          ? "Team #$rank"
                          : "Participant #$rank"),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),

              // Points
              Text(
                "${item.points ?? 0} pts",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
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
  final VoidCallback onManageTap;

  const _RulesAndOverviewTab({
    required this.competition,
    required this.isOwner,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwner) ...[
            // Quick Manage Banner for Owners
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
                      "Manage settings, participants & points",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
            "Description",
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

          const Text(
            "Rules & Information",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          12.vs,
          _InfoTile(
            icon: Icons.emoji_events_outlined,
            title: "Fair Scoring",
            subtitle: "Points update live on the leaderboard.",
          ),
          10.vs,
          _InfoTile(
            icon: Icons.groups_outlined,
            title: "Competition Format",
            subtitle: competition.type == "team"
                ? "Team-based rankings and collaboration."
                : "Individual competitor standings.",
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          12.hs,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                2.vs,
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
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

// =============================================================================
// SLIVER TAB BAR DELEGATE
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