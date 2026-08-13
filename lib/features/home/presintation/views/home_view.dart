import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/views/competition_search_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ Custom Top Bar
              _buildTopBar(context),
              20.vs,

              // 2️⃣ Profile Header Card
              _buildProfileHeaderCard(),
              16.vs,

              // 3️⃣ Quick Stats Grid Bar (4 Columns)
              _buildQuickStatsBar(),
              24.vs,

              // 4️⃣ My Competitions Section
              _buildSectionTitle("My Competitions", onSeeAllTap: () {}),
              12.vs,
              _buildMyCompetitionsHorizontalList(),
              24.vs,

              // 5️⃣ Search & Filter Trigger Bar
              _buildSearchBar(context),
              24.vs,

              // 6️⃣ Recent Activity Section
              _buildSectionTitle("Recent Activity", onSeeAllTap: () {}),
              12.vs,
              _buildRecentActivityList(),
              16.vs,
            ],
          ),
        ),
      ),
    );
  }

  // --- 1️⃣ TOP APP BAR ---
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Icon Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber, size: 22),
            onPressed: () {},
          ),
        ),

        // Brand Logo Center
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
            8.hs,
            const Text(
              "PTOOK",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        // Notification Icon with Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined,
                    color: Colors.amber, size: 22),
                onPressed: () {},
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2️⃣ PROFILE HEADER CARD ---
  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // User Avatar with Glow Border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, color: Colors.white70, size: 28),
            ),
          ),
          14.hs,

          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Hi, Ahmed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    6.hs,
                    const Text("👋", style: TextStyle(fontSize: 16)),
                  ],
                ),
                4.vs,
                Text(
                  "Ready to compete today?",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Total Points Counter
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "2,850",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              2.vs,
              Text(
                "Total Points",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3️⃣ QUICK STATS BAR ---
  Widget _buildQuickStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.emoji_events_outlined, "8", "COMPETITIONS"),
          _buildStatItem(Icons.groups_outlined, "3", "TEAMS"),
          _buildStatItem(Icons.trending_up, "1st", "BEST RANK"),
          _buildStatItem(Icons.local_fire_department_outlined, "12", "DAY STREAK"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        6.vs,
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        4.vs,
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --- SECTION TITLE HELPER ---
  Widget _buildSectionTitle(String title, {required VoidCallback onSeeAllTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: const Text(
            "View all",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // --- 4️⃣ MY COMPETITIONS HORIZONTAL LIST ---
  Widget _buildMyCompetitionsHorizontalList() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildCompetitionCard(
            title: "Flutter Battle",
            subtitle: "Teams • 12 members",
            points: "1,250 pts",
            badgeNumber: "1",
            isSelected: true,
            icon: Icons.workspace_premium,
          ),
          16.hs,
          _buildCompetitionCard(
            title: "Study Challenge",
            subtitle: "Individuals • 35 members",
            points: "980 pts",
            badgeNumber: null,
            isSelected: false,
            icon: Icons.grid_view_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionCard({
    required String title,
    required String subtitle,
    required String points,
    required String? badgeNumber,
    required bool isSelected,
    required IconData icon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 170,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.white10,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              10.vs,

              // Top Image / Trophy Thumbnail Container
              Container(
                height: 56,
                width: 72,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.amber, size: 32),
              ),

              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.vs,
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              // Bottom Points Pill Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.emoji_events,
                          color: Colors.amber, size: 12),
                      4.hs,
                    ],
                    Text(
                      points,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Badge Icon on Top Right corner if rank active
        if (badgeNumber != null)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeNumber,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- 5️⃣ SEARCH BAR ---
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<SearchCompetitionCubit>(),
              child: const CompetitionSearchView(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.4),
            ),
            12.hs,
            Text(
              "Search for a competition...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.filter_list,
              color: Colors.amber,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // --- 6️⃣ RECENT ACTIVITY SECTION ---
  Widget _buildRecentActivityList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildActivityItem(
            badgeWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  "+50",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: "You added 50 points to Ali",
            subtitle: "Flutter Battle",
            time: "2m ago",
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildActivityItem(
            badgeWidget: const CircleAvatar(
              radius: 19,
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            title: "Sara joined Study Challenge",
            subtitle: "Study Challenge",
            time: "10m ago",
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildActivityItem(
            badgeWidget: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  "+30",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: "Mohamed earned 30 points",
            subtitle: "Gym Warriors",
            time: "1h ago",
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required Widget badgeWidget,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        badgeWidget,
        12.hs,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.vs,
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}