import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class TeamExpansionCard extends StatelessWidget {
  final TeamEntity team;
  final int rank;
  final Widget? rankBadge;
  final bool isJoined;
  final bool hasJoinedOtherTeam;
  final String currentUserId;
  final bool isCompetitionEnded;
  final int? maxMembersLimit;
  final bool isActionPending;
  final VoidCallback onToggleJoin;

  const TeamExpansionCard({
    super.key,
    required this.team,
    required this.rank,
    this.rankBadge,
    required this.isJoined,
    required this.hasJoinedOtherTeam,
    required this.currentUserId,
    required this.isCompetitionEnded,
    required this.maxMembersLimit,
    required this.isActionPending,
    required this.onToggleJoin,
  });

  String _getButtonText({required bool isPrivate, required bool isFull}) {
    if (isJoined) return 'Leave';
    if (isFull) return 'Full';
    if (hasJoinedOtherTeam) return 'Switch';
    return isPrivate ? 'Join (Code)' : 'Join';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.goldAccent;
      case 2:
        return AppColors.silverAccent;
      case 3:
        return AppColors.bronzeAccent;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrivate = team.isPrivate;
    final bool isFull = maxMembersLimit != null &&
        team.members.length >= maxMembersLimit! &&
        !isJoined;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJoined ? AppColors.primaryPurple : AppColors.borderOutline,
          width: isJoined ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            rankBadge ??
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: _getRankColor(rank),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          team.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isPrivate ? Icons.lock_outline : Icons.public,
                        size: 14,
                        color: isPrivate
                            ? AppColors.privateRed
                            : AppColors.publicGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${team.totalPoints} pts • ${team.members.length}'
                    '${maxMembersLimit != null ? '/$maxMembersLimit' : ''} members',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompetitionEnded) ...[
              ElevatedButton(
                onPressed: (isFull || isActionPending) ? null : onToggleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : (isFull ? Colors.white10 : AppColors.primaryPurple),
                  foregroundColor: isJoined
                      ? Colors.redAccent
                      : (isFull ? Colors.white38 : Colors.white),
                  elevation: 0,
                  side: isJoined
                      ? const BorderSide(color: Colors.redAccent, width: 1)
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  _getButtonText(isPrivate: isPrivate, isFull: isFull),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}