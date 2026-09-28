import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/activity/domain/entities/activity_entity.dart';
import 'package:ptook/features/activity/presintation/cubit/activity_cubit.dart';
import 'package:ptook/features/activity/presintation/cubit/activity_state.dart';
import 'package:ptook/features/shared/presintation/widgets/banner_ad_widget.dart';

class ActivityView extends StatelessWidget {
  final String userId;

  const ActivityView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Activity Log",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ActivityError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (state is ActivityLoaded) {
            final activities = state.filteredActivities;

            return Column(
              children: [
                _buildFilterChips(context, state.filterType),
                Expanded(
                  child: activities.isEmpty
                      ? const Center(
                          child: Text(
                            "No activity logged yet.",
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: activities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _ActivityCard(item: activities[index]);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildFilterChips(BuildContext context, ActivityType? currentFilter) {
    final cubit = context.read<ActivityCubit>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChipItem(
            label: "All",
            isSelected: currentFilter == null,
            onSelected: () => cubit.filterActivities(null),
          ),
          _FilterChipItem(
            label: "⚡ Power",
            isSelected: currentFilter == ActivityType.powerEarned ||
                currentFilter == ActivityType.powerSpent,
            onSelected: () => cubit.filterActivities(ActivityType.powerEarned),
          ),
          _FilterChipItem(
            label: "🏆 Competitions",
            isSelected: currentFilter == ActivityType.competitionJoined ||
                currentFilter == ActivityType.competitionLeft ||
                currentFilter == ActivityType.competitionCreated ||
                currentFilter == ActivityType.competitionWon,
            onSelected: () =>
                cubit.filterActivities(ActivityType.competitionJoined),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: const Color(0xFF14161D),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityEntity item;

  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case ActivityType.powerEarned:
        icon = Icons.bolt_rounded;
        iconColor = Colors.amber;
        break;
      case ActivityType.powerSpent:
        icon = Icons.bolt_outlined;
        iconColor = Colors.redAccent;
        break;
      case ActivityType.competitionJoined:
        icon = Icons.sports_esports_rounded;
        iconColor = AppColors.primary;
        break;
      case ActivityType.competitionLeft:
        icon = Icons.exit_to_app_rounded;
        iconColor = Colors.orangeAccent;
        break;
      case ActivityType.competitionCreated:
        icon = Icons.add_circle_outline_rounded;
        iconColor = Colors.purpleAccent;
        break;
      case ActivityType.competitionWon:
        icon = Icons.emoji_events_rounded;
        iconColor = Colors.amberAccent;
        break;
      case ActivityType.invitation:
        icon = Icons.mail_outline_rounded;
        iconColor = Colors.lightBlueAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(item.timestamp),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}