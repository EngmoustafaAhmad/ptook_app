import 'package:flutter/material.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

class PodiumView extends StatelessWidget {
  final List<dynamic> sortedList;

  const PodiumView({required this.sortedList});

  @override
  Widget build(BuildContext context) {
    // Safely extract top 3 candidates without index errors
    final first = sortedList.isNotEmpty ? sortedList[0] : null;
    final second = sortedList.length > 1 ? sortedList[1] : null;
    final third = sortedList.length > 2 ? sortedList[2] : null;

    if (first == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place (Silver) - Only render if 2nd participant exists
        if (second != null)
          _PodiumColumn(
            name: second.name ?? "Runner Up",
            avatarUrl: second.avatarUrl,
            points: second.points ?? 0,
            rank: 2,
            height: 90,
            color: const Color(0xFFC0C0C0),
          )
        else
          const SizedBox(width: 80), // Spacer placeholder for visual balance

        12.hs,

        // 1st Place (Gold)
        _PodiumColumn(
          name: first.name ?? "Leader",
          avatarUrl: first.avatarUrl,
          points: first.points ?? 0,
          rank: 1,
          height: 120,
          color: const Color(0xFFFFD700),
        ),

        12.hs,

        // 3rd Place (Bronze) - Only render if 3rd participant exists
        if (third != null)
          _PodiumColumn(
            name: third.name ?? "Participant",
            avatarUrl: third.avatarUrl,
            points: third.points ?? 0,
            rank: 3,
            height: 70,
            color: const Color(0xFFCD7F32),
          )
        else
          const SizedBox(width: 80), // Spacer placeholder
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final int points;
  final int rank;
  final double height;
  final Color color;

  const _PodiumColumn({
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Badge Overlay
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
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
        8.vs,

        // Name & Score
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        2.vs,
        Text(
          "$points pts",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.vs,

        // Podium Block Graphic
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Center(
            child: Icon(Icons.emoji_events, color: color, size: 28),
          ),
        ),
      ],
    );
  }
}