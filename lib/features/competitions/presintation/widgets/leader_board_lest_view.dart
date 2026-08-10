import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

class LeaderboardListView extends StatelessWidget {
  final List<dynamic> sortedList;
  final String? currentUserId;
  final bool isTeamType;
  final bool isOwner;

  const LeaderboardListView({
    super.key, 
    required this.sortedList,
    required this.currentUserId,
    required this.isTeamType,
    required this.isOwner,
  });

  /// Computes display rank taking ties into account
  int _calculateRank(int index) {
    if (index == 0) return 1;
    final currentPoints = sortedList[index].points ?? 0;
    final previousPoints = sortedList[index - 1].points ?? 0;

    if (currentPoints == previousPoints) {
      // Same score as previous participant -> Same rank
      return _calculateRank(index - 1);
    }
    return index + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (sortedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined,
                size: 48, color: Colors.white.withOpacity(0.3)),
            12.vs,
            Text(
              isTeamType ? "No teams joined yet" : "No participants joined yet",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => 8.vs,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final isCurrentUser = item.id == currentUserId;
        final rank = _calculateRank(index);

        return _LeaderboardTile(
          item: item,
          rank: rank,
          isCurrentUser: isCurrentUser,
          isTeamType: isTeamType,
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final dynamic item;
  final int rank;
  final bool isCurrentUser;
  final bool isTeamType;

  const _LeaderboardTile({
    required this.item,
    required this.rank,
    required this.isCurrentUser,
    required this.isTeamType,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();

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
          // Rank Badge
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

          // User / Team Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              isTeamType ? Icons.groups : Icons.person,
              size: 20,
              color: isCurrentUser ? AppColors.primary : Colors.white70,
            ),
          ),
          12.hs,

          // Participant Name & "YOU" Indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name ?? (isTeamType ? "Team" : "Participant"),
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
                            horizontal: 6, vertical: 1),
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
              ],
            ),
          ),

          // Score Display
          Text(
            "${item.points ?? 0} pts",
            style: TextStyle(
              color: isCurrentUser ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
