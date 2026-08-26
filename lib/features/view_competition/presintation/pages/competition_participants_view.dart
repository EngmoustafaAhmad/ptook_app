import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';

// =============================================================================
// DESIGN SYSTEM TOKENS
// =============================================================================

abstract class AppColors {
  static const background = Color(0xFF0C0E12);
  static const cardBackground = Color(0xFF14171F);
  static const cardBorder = Color(0x12FFFFFF);
  static const primaryGold = Color(0xFFFFC72C);
  static const primaryGoldGlow = Color(0x33FFC72C);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x99FFFFFF);
  static const textMuted = Color(0x66FFFFFF);
  static const divider = Color(0x12FFFFFF);
  static const error = Color(0xFFFF5252);
}

// =============================================================================
// COMPETITION PARTICIPANTS VIEW
// =============================================================================

class CompetitionParticipantsView extends StatefulWidget {
  final String competitionId;
  final String? currentUserId;

  const CompetitionParticipantsView({
    super.key,
    required this.competitionId,
    this.currentUserId,
  });

  @override
  State<CompetitionParticipantsView> createState() =>
      _CompetitionParticipantsViewState();
}

class _CompetitionParticipantsViewState
    extends State<CompetitionParticipantsView> {
  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  void _fetchParticipants() {
    context.read<ViewParticipantsCubit>().listenToParticipants(widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'PARTICIPANTS',
          style: TextStyle(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
        listener: (context, state) {
          if (state is ViewParticipantsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ViewParticipantsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 2.5,
              ),
            );
          }

          if (state is ViewParticipantsError) {
            return _ErrorStateWidget(
              message: state.message,
              onRetry: _fetchParticipants,
            );
          }

          if (state is ViewParticipantsLoaded) {
            if (state.participants.isEmpty) {
              return _EmptyStateWidget(onRefresh: _fetchParticipants);
            }

            return RefreshIndicator(
              color: AppColors.primaryGold,
              backgroundColor: AppColors.cardBackground,
              onRefresh: () async => _fetchParticipants(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                itemCount: state.participants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final participant = state.participants[index];
                  final isCurrentUser =
                      participant.id == widget.currentUserId;

                  return _ParticipantTile(
                    participant: participant,
                    rank: index + 1,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

class _ParticipantTile extends StatelessWidget {
  final ParticipantEntity participant;
  final int rank;
  final bool isCurrentUser;

  const _ParticipantTile({
    required this.participant,
    required this.rank,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
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
          // Rank Badge
          _RankBadge(rank: rank),
          const SizedBox(width: 12),

          // Avatar
          _ParticipantAvatar(imageUrl: participant.avatarUrl, name: participant.name),
          const SizedBox(width: 12),

          // Participant Info
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

          // Score / Status
          if (participant.points != null) ...[
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
        color: isTop3
            ? badgeColor.withValues(alpha: 0.15)
            : Colors.transparent,
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
    final fallbackInitial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryGold.withValues(alpha: 0.15),
        border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackText(fallbackInitial),
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

class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyStateWidget({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Participants Yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first one to join this competition!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryGold),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}