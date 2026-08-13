import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/competitions/presintation/views/competition_home_view.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart'
    hide JoinCompetitionSuccess, LeaveCompetitionSuccess;

import '../../domain/entities/competition_entity.dart';

/// 🎨 App Color Constants matching the Dark Theme UI
abstract class _ViewColors {
  static const background = Color(0xFF101216);
  static const cardBackground = Color(0xFF181A20);
  static const primaryGold = Color(0xFFFFC72C);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x99FFFFFF);
  static const divider = Color(0x1AFFFFFF);
}

class CompetitionDetailsView extends StatelessWidget {
  final CompetitionEntity competition;

  const CompetitionDetailsView({
    super.key,
    required this.competition, 
    required String currentUserId, 
    required String competitionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ParticipantCubit>(),
      child: _CompetitionDetailsContent(competition: competition),
    );
  }
}

class _CompetitionDetailsContent extends StatelessWidget {
  final CompetitionEntity competition;

  const _CompetitionDetailsContent({required this.competition});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwner = competition.ownerId == currentUserId;
    final isJoined = competition.isJoinedBy(currentUserId);

    return BlocListener<ParticipantCubit, dynamic>(
      listener: (context, state) => _handleBlocState(context, state, currentUserId),
      child: Scaffold(
        backgroundColor: _ViewColors.background,
        appBar: AppBar(
          backgroundColor: _ViewColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            competition.name.toUpperCase(),
            style: const TextStyle(
              color: _ViewColors.primaryGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.more_vert, color: _ViewColors.textSecondary),
                onPressed: () {
                  // Navigate to Settings / Management View
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Optional Banner
                        if (competition.imageUrl != null) ...[
                          _CompetitionBanner(imageUrl: competition.imageUrl!),
                          const SizedBox(height: 16),
                        ],

                        // Badges Row (Category, Type, Status)
                        _BadgesRow(competition: competition),
                        const SizedBox(height: 16),

                        // Title & Description
                        Text(
                          competition.name,
                          style: const TextStyle(
                            color: _ViewColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          competition.description,
                          style: const TextStyle(
                            color: _ViewColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: _ViewColors.divider, thickness: 1),
                        const SizedBox(height: 20),

                        // Stats Grid (Cards with watermark icons)
                        _StatCard(
                          icon: Icons.stars_rounded,
                          title: 'Total Points',
                          value: '${competition.totalPoints} pts',
                          watermarkIcon: Icons.star_border_rounded,
                        ),
                        const SizedBox(height: 12),

                        _ParticipantsCard(competition: competition),
                        const SizedBox(height: 12),

                        _StatCard(
                          icon: Icons.calendar_today_rounded,
                          title: 'Ends On',
                          value:
                              '${competition.endDate.day}/${competition.endDate.month}/${competition.endDate.year}',
                          watermarkIcon: Icons.calendar_month_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                _ActionButtonSection(
                  competition: competition,
                  isOwner: isOwner,
                  isJoined: isJoined,
                  currentUserId: currentUserId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// BLoC state listener callback
  void _handleBlocState(BuildContext context, dynamic state, String currentUserId) {
    if (state is JoinCompetitionSuccess) {
      final updatedCompetition = competition.copyWith(
        participantIds: [...competition.participantIds, currentUserId],
        participantsCount: competition.participantsCount + 1,
      );

      _showSnackBar(context, 'Successfully joined the competition!', Colors.green);
      Navigator.pop(context, updatedCompetition);
    } else if (state is LeaveCompetitionSuccess) {
      final updatedCompetition = competition.copyWith(
        participantIds:
            competition.participantIds.where((id) => id != currentUserId).toList(),
        participantsCount:
            competition.participantsCount > 0 ? competition.participantsCount - 1 : 0,
      );

      _showSnackBar(context, 'You have left the competition.', _ViewColors.textSecondary);
      Navigator.pop(context, updatedCompetition);
    } else if (state is ParticipantError) {
      _showSnackBar(context, state.message, Colors.redAccent);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS
// =============================================================================

/// Top Banner Image
class _CompetitionBanner extends StatelessWidget {
  final String imageUrl;
  const _CompetitionBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Category, Type & Status Pill Row
class _BadgesRow extends StatelessWidget {
  final CompetitionEntity competition;
  const _BadgesRow({required this.competition});

  @override
  Widget build(BuildContext context) {
    final isLive = competition.status.toLowerCase() == 'active';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _BadgePill(
          label: competition.category.toUpperCase(),
          borderColor: _ViewColors.primaryGold,
          textColor: _ViewColors.primaryGold,
        ),
        _BadgePill(
          label: competition.type.toUpperCase(),
          borderColor: _ViewColors.primaryGold,
          textColor: _ViewColors.primaryGold,
        ),
        _BadgePill(
          label: isLive ? 'LIVE' : competition.status.toUpperCase(),
          backgroundColor: isLive
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.amber.withOpacity(0.2),
          borderColor: isLive ? Colors.blueAccent : Colors.amber,
          textColor: isLive ? Colors.blueAccent : Colors.amber,
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _BadgePill({
    required this.label,
    this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Reusable dark stat card with background watermark icon
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final IconData watermarkIcon;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.watermarkIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ViewColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              watermarkIcon,
              size: 80,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: _ViewColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ViewColors.primaryGold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  color: _ViewColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Specialized Participants Card with Progress Bar
class _ParticipantsCard extends StatelessWidget {
  final CompetitionEntity competition;
  const _ParticipantsCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    final max = competition.maxParticipants;
    final count = competition.participantsCount;
    final progress = (max != null && max > 0) ? (count / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ViewColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.people_alt_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.group_rounded, color: _ViewColors.primaryGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Participants',
                    style: TextStyle(
                      color: _ViewColors.primaryGold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$count ',
                      style: TextStyle(
                        color: _ViewColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (max != null)
                      TextSpan(
                        text: '/ $max',
                        style: const TextStyle(
                          color: _ViewColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (max != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_ViewColors.primaryGold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Dynamic Bottom Action Buttons
class _ActionButtonSection extends StatelessWidget {
  final CompetitionEntity competition;
  final bool isOwner;
  final bool isJoined;
  final String currentUserId;

  const _ActionButtonSection({
    required this.competition,
    required this.isOwner,
    required this.isJoined,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParticipantCubit, dynamic>(
      builder: (context, state) {
        if (state is ParticipantLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(color: _ViewColors.primaryGold),
            ),
          );
        }

        // 1. Owner View
        if (isOwner) {
          return _PrimaryButton(
            label: 'Manage Competition',
            icon: Icons.grid_view_rounded,
            onPressed: () {
              // Navigate to Manager Dashboard
            },
          );
        }

        // 2. Joined View
        if (isJoined) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrimaryButton(
                label: 'Open Dashboard',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  // 1. Get the current logged-in user's ID
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
              
                  // 2. Navigate and provide a fresh ParticipantCubit instance
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => sl<ParticipantCubit>(), // 👈 Service locator injection
                        child: CompetitionHomeView(
                          competition: competition,
                          currentUserId: currentUserId, 
                          competitionId: competition.id,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showLeaveDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text(
                  'Leave Competition',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        }

        // 3. Not Joined View
        final isFull = competition.maxParticipants != null &&
            competition.participantsCount >= competition.maxParticipants!;

        return _PrimaryButton(
          label: isFull ? 'Competition Full' : 'Join Competition',
          isDisabled: isFull,
          onPressed: isFull
              ? null
              : () {
                  context.read<ParticipantCubit>().joinCompetition(
                        competitionId: competition.id,
                        userId: currentUserId,
                      );
                },
        );
      },
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _ViewColors.cardBackground,
        title: const Text(
          'Leave Competition?',
          style: TextStyle(color: _ViewColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to leave this competition? Your rank and progress will be lost.',
          style: TextStyle(color: _ViewColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ParticipantCubit>().leaveCompetition(
                    competitionId: competition.id,
                    userId: currentUserId,
                  );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// Custom Rounded Primary Button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade800 : _ViewColors.primaryGold,
          foregroundColor: isDisabled ? Colors.white38 : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}