// lib/features/auth/presintation/views/home_view.dart

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ Header Section
              _buildHeader(),
              24.vs,

              // 2️⃣ Quick Stats Section
              _buildSectionTitle(Icons.bar_chart, "Quick Stats"),
              12.vs,
              _buildQuickStats(),
              24.vs,

              // 3️⃣ My Competitions Section
              _buildSectionTitle(Icons.emoji_events_outlined, "My Competitions", hasViewAll: true),
              12.vs,
              _buildMyCompetitionsList(),
              24.vs,

              // 4️⃣ Explore Competitions Section
              _buildSectionTitle(Icons.explore_outlined, "Explore Competitions", hasViewAll: true),
              12.vs,
              _buildExploreCompetitionsList(),
              24.vs,

              // 5️⃣ Search & Filter Bar
              _buildSearchBar(context),
              24.vs,

              // 6️⃣ Recent Activity Section
              _buildSectionTitle(Icons.flash_on, "Recent Activity", hasViewAll: true),
              12.vs,
              _buildRecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets البناء المخصصة للتصميم ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.primary, size: 28),
                8.hs,
                const Text(
                  "PTOOK",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ],
            ),
            12.vs,
            const Text(
              "Welcome back, Ahmed 👋",
              style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            4.vs,
            Text(
              "Let's keep competing and winning!",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.primary, size: 28),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, {bool hasViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            8.hs,
            Text(
              title,
              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (hasViewAll)
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Text("View All", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.6), size: 10),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(Icons.star, "2,450", "Total Points"),
        12.hs,
        _buildStatCard(Icons.emoji_events, "#4", "Best Rank"),
        12.hs,
        _buildStatCard(Icons.group, "7", "Joined Competitions"),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            8.vs,
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            4.vs,
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCompetitionsList() {
    return Column(
      children: [
        _buildMyCompetitionCard("Flutter Championship", "Individual", "128 Members", "#4", "540", const Icon(Icons.emoji_events, color: Colors.amber)),
        12.vs,
        _buildMyCompetitionCard("Code Warriors", "Team", "8 Teams", "#2", "1,280", const Icon(Icons.shield, color: Colors.amber)),
      ],
    );
  }

  Widget _buildMyCompetitionCard(String title, String type, String members, String rank, String points, Widget icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
            child: icon,
          ),
          12.hs,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    8.hs,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Text(type, style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                    )
                  ],
                ),
                8.vs,
                Row(
                  children: [
                    Icon(Icons.group_outlined, size: 14, color: Colors.white.withOpacity(0.5)),
                    4.hs,
                    Text(members, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    16.hs,
                    Icon(Icons.bar_chart, size: 14, color: Colors.white.withOpacity(0.5)),
                    4.hs,
                    Text("Your Rank: $rank", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Your Points", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
              Text(points, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          12.hs,
          Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 16),
        ],
      ),
    );
  }

  Widget _buildExploreCompetitionsList() {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildExploreCard("Code Sprint 2026", "Individual", "96 Members", Icons.code),
          12.hs,
          _buildExploreCard("Dev Teams Cup", "Team", "16 Teams", Icons.security),
          12.hs,
          _buildExploreCard("Speed Coders", "Individual", "64 Members", Icons.flash_on),
        ],
      ),
    );
  }

  Widget _buildExploreCard(String title, String type, String count, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 36),
          12.vs,
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          4.vs,
          Text(type, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
          8.vs,
          Text(count, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Join", style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
  return GestureDetector(
    onTap: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<SearchCompetitionCubit>()
              ..loadPublicCompetitions(),
      
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
        borderRadius: BorderRadius.circular(12),
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
            ),
          ),


          const Spacer(),

          Icon(
            Icons.filter_list,
            color: AppColors.primary,
          )

        ],
      ),
    ),
  );
}

  Widget _buildRecentActivityList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildActivityItem("You earned 50 points in Flutter Championship", "2 hours ago", "+50 pts"),
          const Divider(color: Colors.black26),
          _buildActivityItem("Your team earned 100 points in Code Warriors", "Yesterday", "+100 pts"),
          const Divider(color: Colors.black26),
          _buildActivityItem("You moved up to #4 in Flutter Championship", "2 days ago", null, isRankUp: true),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, String? pts, {bool isRankUp = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            child: Icon(
              isRankUp ? Icons.trending_up : Icons.add,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          12.hs,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                4.vs,
                Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          if (pts != null)
            Text(pts, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}