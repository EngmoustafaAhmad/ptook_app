import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart' hide JoinCompetitionSuccess, LeaveCompetitionSuccess;

import '../../domain/entities/competition_entity.dart';


class CompetitionDetailsView extends StatelessWidget {
  final CompetitionEntity competition;

  const CompetitionDetailsView({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isOwner = competition.ownerId == currentUserId;
    final bool isJoined = competition.isJoinedBy(currentUserId);

    return BlocListener<ParticipantCubit, dynamic>(
      listener: (context, state) {
        // 🎯 1. Handle Join Success
        if (state is JoinCompetitionSuccess) {
          final updatedCompetition = competition.copyWith(
            participantIds: [...competition.participantIds, currentUserId],
            participantsCount: competition.participantsCount + 1,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined the competition!'),
              backgroundColor: Colors.green,
            ),
          );

          // Return updated entity to previous screen (Search / Feed)
          Navigator.pop(context, updatedCompetition);
        }

        // 🎯 2. Handle Leave Success
        if (state is LeaveCompetitionSuccess) {
          final updatedCompetition = competition.copyWith(
            participantIds: competition.participantIds
                .where((id) => id != currentUserId)
                .toList(),
            participantsCount: competition.participantsCount > 0
                ? competition.participantsCount - 1
                : 0,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have left the competition.'),
            ),
          );

          // Return updated entity to previous screen (Search / Feed)
          Navigator.pop(context, updatedCompetition);
        }

        // 🎯 3. Handle Error State
        if (state is ParticipantError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(competition.name),
          actions: [
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to Owner Settings / Management View
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner / Image if available
                if (competition.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      competition.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                // Category & Type Badges
                Row(
                  children: [
                    _buildBadge(
                      label: competition.category.toUpperCase(),
                      color: Colors.blue.shade100,
                      textColor: Colors.blue.shade800,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      label: competition.type.toUpperCase(),
                      color: Colors.purple.shade100,
                      textColor: Colors.purple.shade800,
                    ),
                    const Spacer(),
                    _buildBadge(
                      label: competition.status.toUpperCase(),
                      color: competition.status == 'active'
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                      textColor: competition.status == 'active'
                          ? Colors.green.shade900
                          : Colors.amber.shade900,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Competition Name & Description
                Text(
                  competition.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  competition.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                // Competition Statistics / Info Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoTile(
                      context,
                      icon: Icons.emoji_events_outlined,
                      title: 'Total Points',
                      value: '${competition.totalPoints} pts',
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.people_outline,
                      title: 'Participants',
                      value: competition.maxParticipants != null
                          ? '${competition.participantsCount} / ${competition.maxParticipants}'
                          : '${competition.participantsCount}',
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: 'Ends On',
                      value:
                          '${competition.endDate.day}/${competition.endDate.month}/${competition.endDate.year}',
                    ),
                  ],
                ),

                const Spacer(),

                // 🎯 Action Button Section
                BlocBuilder<ParticipantCubit, dynamic>(
                  builder: (context, state) {
                    final isLoading = state is ParticipantLoading;

                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (isOwner) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to Manager Dashboard
                          },
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Manage Competition'),
                        ),
                      );
                    }

                    if (isJoined) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // Navigate to Joined Participant Dashboard
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Open Dashboard'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showLeaveDialog(
                              context,
                              currentUserId,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Leave Competition'),
                          ),
                        ],
                      );
                    }

                    // Not joined state
                    final isFull = competition.maxParticipants != null &&
                        competition.participantsCount >=
                            competition.maxParticipants!;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFull ? Colors.grey : Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isFull
                            ? null
                            : () {
                                context.read<ParticipantCubit>().joinCompetition(
                                      competitionId: competition.id,
                                      userId: currentUserId,
                                    );
                              },
                        child: Text(
                          isFull ? 'Competition Full' : 'Join Competition',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmation Modal before leaving
  void _showLeaveDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Competition?'),
        content: const Text(
          'Are you sure you want to leave this competition? Your current rank and accumulated progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ParticipantCubit>().leaveCompetition(
                    competitionId: competition.id,
                    userId: userId,
                  );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  /// Helper for info grid
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Helper for visual status badges
  Widget _buildBadge({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}