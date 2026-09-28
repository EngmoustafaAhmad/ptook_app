import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_participants_view_all.dart';

class IndividualOverviewTabView extends StatelessWidget {
  const IndividualOverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
      builder: (context, compState) {
        if (compState.status == ManageCompetitionStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFC107),
              strokeWidth: 2.5,
            ),
          );
        }

        if (compState.status == ManageCompetitionStatus.deleted ||
            compState.competition == null) {
          return const Center(
            child: Text(
              'Competition no longer exists.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final currentComp = compState.competition!;

        return BlocBuilder<ParticipantManagementCubit, ParticipantManagementState>(
          builder: (context, partState) {
            final participants = partState.participants;
            final totalPoints = participants.fold<int>(
              0,
              (sum, item) => sum + item.points,
            );
            final maxParticipants = currentComp.maxParticipants;
            final fillPercentage = maxParticipants! > 0
                ? (participants.length / maxParticipants).clamp(0.0, 1.0)
                : 0.0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header Section
                      _buildHeader(currentComp.status),
                      const SizedBox(height: 16),

                      // Metrics Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'MAX CAPACITY',
                              value: '$maxParticipants',
                              icon: Icons.groups_outlined,
                              accentColor: const Color(0xFF64B5F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              label: 'TOTAL SCORE',
                              value: '$totalPoints',
                              icon: Icons.stars_rounded,
                              accentColor: const Color(0xFFFFC107),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Occupancy Card with Progress Bar
                      _OccupancyCard(
                        joined: participants.length,
                        total: maxParticipants,
                        percentage: fillPercentage,
                      ),
                      const SizedBox(height: 24),

                      // Top Performers Card
                      _TopPerformersCard(
                          participants: participants,
                          onViewAllTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (context) => sl<ViewParticipantsCubit>(),
                                  child: CompetitionParticipantsViewAll(
                                    competitionId: currentComp.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),

                      // Admin Controls
                      const _AdminActionsCard(),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String status) {
    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? const Color(0xFF4CAF50) : Colors.orangeAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Overview & Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopPerformersCard extends StatelessWidget {
  final List<ParticipantEntity> participants;
  final VoidCallback onViewAllTap;

  const _TopPerformersCard({
    required this.participants,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final topThree = (List<ParticipantEntity>.from(participants)
          ..sort((a, b) => b.points.compareTo(a.points)))
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Performers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF9C27B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (topThree.isEmpty) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'No participants joined yet',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topThree.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final participant = topThree[index];
                  final hasAvatar = participant.avatarUrl != null && participant.avatarUrl!.trim().isNotEmpty;
                  final fallbackInitial = participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?';

                  return Row(
                    children: [
                      // 1️⃣ Cached Avatar Image with Fallback Initial
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                        backgroundImage: hasAvatar
                            ? CachedNetworkImageProvider(participant.avatarUrl!)
                            : null,
                        child: !hasAvatar
                            ? Text(
                                fallbackInitial,
                                style: const TextStyle(
                                  color: Color(0xFF9C27B0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // 2️⃣ Name
                      Expanded(
                        child: Text(
                          participant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 3️⃣ Points
                      Text(
                        '${participant.points} pts',
                        style: const TextStyle(
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: accentColor.withAlpha(180)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  final int joined;
  final int total;
  final double percentage;

  const _OccupancyCard({
    required this.joined,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PARTICIPANT SLOTS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: '$joined',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: ' / $total',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: const Color(0xFF0D0F17),
              color: const Color(0xFFFFC107),
            ),
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
    Color color;
    Color textColor = Colors.black;

    switch (rank) {
      case 1:
        color = const Color(0xFFFFC107);
        break;
      case 2:
        color = const Color(0xFFC0C0C0);
        break;
      case 3:
        color = const Color(0xFFCD7F32);
        textColor = Colors.white;
        break;
      default:
        color = Colors.white.withAlpha(12);
        textColor = Colors.white54;
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminActionsCard extends StatelessWidget {
  const _AdminActionsCard();

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool isDanger = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161925),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDanger ? Colors.redAccent : const Color(0xFFFFC107),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: Text(
              isDanger ? 'Delete' : 'Confirm',
              style: TextStyle(
                color: isDanger ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADMINISTRATION CONTROL',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showConfirmationDialog(
                    context,
                    title: 'Finish Competition',
                    content:
                        'Are you sure you want to finish this competition? Leaderboards will be locked.',
                    onConfirm: () => context
                        .read<ManageCompetitionCubit>()
                        .finishCompetition(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    minimumSize: const Size(0, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                  label: const Text(
                    'FINISH',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showConfirmationDialog(
                    context,
                    title: 'Delete Competition',
                    content: 'This action is permanent and cannot be undone.',
                    isDanger: true,
                    onConfirm: () => context
                        .read<ManageCompetitionCubit>()
                        .deleteCompetition(),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  label: const Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}