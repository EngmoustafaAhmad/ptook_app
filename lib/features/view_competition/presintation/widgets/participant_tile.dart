import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

class ParticipantTile extends StatelessWidget {
  final ParticipantEntity participant;
  final int rank;
  final String? currentUserId;

  const ParticipantTile({
    super.key,
    required this.participant,
    required this.rank,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Checks both participant.userId and participant.id for bulletproof identity matching
    final isCurrentUser = currentUserId != null &&
        (participant.userId == currentUserId || participant.id == currentUserId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryGold.withValues(alpha: 0.08)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primaryGold.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: isCurrentUser ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          _RankBadge(rank: rank),
          const SizedBox(width: 12),
          _ParticipantAvatar(
            imageUrl: participant.avatarUrl,
            name: participant.name,
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
                        participant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight:
                              isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (participant.bio != null && participant.bio!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    participant.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
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
                '${participant.points}',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final badgeColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.textMuted;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTop3 ? badgeColor.withValues(alpha: 0.15) : Colors.transparent,
        border: isTop3 ? Border.all(color: badgeColor, width: 1.5) : null,
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: isTop3 ? badgeColor : AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _ParticipantAvatar({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final fallbackInitial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryGold.withValues(alpha: 0.15),
        border: Border.all(
          color: const Color.fromRGBO(255, 199, 44, 1).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) => _FallbackText(fallbackInitial),
                errorWidget: (context, url, error) =>
                    _FallbackText(fallbackInitial),
              )
            : _FallbackText(fallbackInitial),
      ),
    );
  }
}

class _FallbackText extends StatelessWidget {
  final String initial;
  const _FallbackText(this.initial);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}