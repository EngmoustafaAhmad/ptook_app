import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/views/competition_home_view.dart';
import 'package:ptook/features/competitions/presintation/views/manage_competition_view.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart'
    hide LeaveCompetitionSuccess, JoinCompetitionSuccess;

// =============================================================================
// DESIGN SYSTEM TOKENS
// =============================================================================

abstract class _ViewColors {
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
  static const success = Color(0xFF4CAF50);
}

// =============================================================================
// MAIN ENTRY VIEW
// =============================================================================

class CompetitionDetailsView extends StatelessWidget {
  final CompetitionEntity competition;

  const CompetitionDetailsView({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParticipantCubit>(
      create: (_) => sl<ParticipantCubit>(),
      child: _CompetitionDetailsContent(initialCompetition: competition),
    );
  }
}

// =============================================================================
// CONTENT CONTROLLER
// =============================================================================

class _CompetitionDetailsContent extends StatefulWidget {
  final CompetitionEntity initialCompetition;

  const _CompetitionDetailsContent({required this.initialCompetition});

  @override
  State<_CompetitionDetailsContent> createState() =>
      _CompetitionDetailsContentState();
}

class _CompetitionDetailsContentState
    extends State<_CompetitionDetailsContent> {
  late CompetitionEntity _competition;

  @override
  void initState() {
    super.initState();
    _competition = widget.initialCompetition;
  }

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isOwner => _competition.ownerId == _currentUserId;
  bool get _isJoined => _competition.isJoinedBy(_currentUserId);
  bool get _isFull =>
      _competition.maxParticipants != null &&
      _competition.participantsCount >= _competition.maxParticipants!;

  // Checks if the competition has been finished by status or time expiration
  bool get _isEnded {
    final status = _competition.status.toLowerCase();
    final statusEnded =
        status == 'ended' || status == 'finished' || status == 'completed';
    final dateEnded = DateTime.now().isAfter(_competition.endDate);

    return statusEnded || dateEnded;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantCubit, ParticipantState>(
      listener: _handleStateListener,
      builder: (context, state) {
        final isLoading = state is ParticipantLoading;

        return Scaffold(
          backgroundColor: _ViewColors.background,
          appBar: AppBar(
            backgroundColor: _ViewColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              _competition.name.toUpperCase(),
              style: const TextStyle(
                color: _ViewColors.primaryGold,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 14,
              ),
            ),
            actions: [
              if (_isOwner)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: _ViewColors.textSecondary),
                  onPressed: _onManagePressed,
                ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_competition.imageUrl != null &&
                          _competition.imageUrl!.isNotEmpty) ...[
                        _CompetitionBanner(imageUrl: _competition.imageUrl!),
                        const SizedBox(height: 20),
                      ],
                      _BadgesRow(
                        competition: _competition,
                        isEnded: _isEnded,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _competition.name,
                        style: const TextStyle(
                          color: _ViewColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _competition.description,
                        style: const TextStyle(
                          color: _ViewColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: _ViewColors.divider, thickness: 1),
                      const SizedBox(height: 24),

                      // Metric Grid
                      Row(
                        children: [
                          Expanded(
                            child: _CompactMetricCard(
                              icon: Icons.stars_rounded,
                              title: 'Total Points',
                              value: '${_competition.totalPoints}',
                              unit: 'pts',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CompactMetricCard(
                              icon: Icons.group_rounded,
                              title: 'Participants',
                              value: '${_competition.participantsCount}',
                              unit: _competition.maxParticipants != null
                                  ? '/ ${_competition.maxParticipants}'
                                  : '',
                              progress: _competition.maxParticipants != null &&
                                      _competition.maxParticipants! > 0
                                  ? (_competition.participantsCount /
                                          _competition.maxParticipants!)
                                      .clamp(0.0, 1.0)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TimelineCard(
                        endDate: _competition.endDate,
                        isEnded: _isEnded,
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Bottom Action Dock
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _FloatingBottomDock(
                  competition: _competition,
                  isOwner: _isOwner,
                  isJoined: _isJoined,
                  isFull: _isFull,
                  isEnded: _isEnded,
                  isLoading: isLoading,
                  onJoinPressed: _onJoinPressed,
                  onLeavePressed: () => _showLeaveDialog(context),
                  onOpenDashboardPressed: _navigateToCompetitionHome,
                  onManagePressed: _onManagePressed,
                  onFullPressed: () => _showFullCompetitionDialog(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUSINESS ACTIONS & LISTENERS
  // ---------------------------------------------------------------------------

  void _handleStateListener(BuildContext context, ParticipantState state) {
    if (state is JoinCompetitionSuccess) {
      setState(() {
        _competition = _competition.copyWith(
          participantIds: [..._competition.participantIds, _currentUserId],
          participantsCount: _competition.participantsCount + 1,
        );
      });
      _showSnackBar(context, 'Successfully joined the competition!', _ViewColors.success);
      _navigateToCompetitionHome();
    } else if (state is LeaveCompetitionSuccess) {
      _showSnackBar(context, 'You have left the competition.', _ViewColors.textSecondary);
      Navigator.pop(context);
    } else if (state is ParticipantError) {
      _showSnackBar(context, state.message, _ViewColors.error);
    }
  }

  void _onJoinPressed() {
    context.read<ParticipantCubit>().joinCompetition(
          competitionId: _competition.id,
          userId: _currentUserId,
        );
  }

  void _onLeavePressed() {
    context.read<ParticipantCubit>().leaveCompetition(
          competitionId: _competition.id,
          userId: _currentUserId,
        );
  }

  void _navigateToCompetitionHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<ParticipantCubit>(
          create: (_) => sl<ParticipantCubit>(),
          child: CompetitionHomeView(
            competition: _competition,
            currentUserId: _currentUserId,
            competitionId: _competition.id,
          ),
        ),
      ),
    );
  }

  void _onManagePressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageCompetitionView(competition: _competition),
      ),
    );
  }

  void _showFullCompetitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _ViewColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _ViewColors.cardBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.group_off_rounded, color: _ViewColors.primaryGold, size: 24),
            SizedBox(width: 10),
            Text(
              'Competition Full',
              style: TextStyle(
                color: _ViewColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Maximum capacity has been reached. You cannot join this competition at this moment.',
          style: TextStyle(color: _ViewColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'OK',
              style: TextStyle(color: _ViewColors.primaryGold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _ViewColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _ViewColors.cardBorder),
        ),
        title: const Text(
          'Leave Competition?',
          style: TextStyle(
            color: _ViewColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to leave this competition? Your rank and progress will be reset.',
          style: TextStyle(color: _ViewColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _ViewColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              _onLeavePressed();
            },
            child: const Text('Leave', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// =============================================================================
// UI COMPONENTS & CARDS
// =============================================================================

class _CompetitionBanner extends StatelessWidget {
  final String imageUrl;
  const _CompetitionBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final CompetitionEntity competition;
  final bool isEnded;

  const _BadgesRow({
    required this.competition,
    required this.isEnded,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = competition.status.toLowerCase();
    final isLive = statusLower == 'active' && !isEnded;

    Color statusColor;
    String statusText;

    if (isEnded) {
      statusColor = _ViewColors.error;
      statusText = 'ENDED';
    } else if (isLive) {
      statusColor = const Color(0xFF00E676);
      statusText = 'LIVE';
    } else {
      statusColor = Colors.amber;
      statusText = competition.status.toUpperCase();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _BadgePill(
          label: competition.category.toUpperCase(),
          borderColor: _ViewColors.primaryGold.withValues(alpha: 0.6),
          textColor: _ViewColors.primaryGold,
        ),
        _BadgePill(
          label: competition.type.toUpperCase(),
          borderColor: _ViewColors.textSecondary.withValues(alpha: 0.3),
          textColor: _ViewColors.textPrimary,
        ),
        _BadgePill(
          label: statusText,
          backgroundColor: statusColor.withValues(alpha: 0.15),
          borderColor: statusColor,
          textColor: statusColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final double? progress;

  const _CompactMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.unit = '',
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ViewColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ViewColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _ViewColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _ViewColors.primaryGold, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ViewColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: _ViewColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: _ViewColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    _ViewColors.primaryGold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final DateTime endDate;
  final bool isEnded;

  const _TimelineCard({
    required this.endDate,
    required this.isEnded,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${endDate.day} ${_months[endDate.month - 1]}, ${endDate.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ViewColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ViewColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _ViewColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: _ViewColors.primaryGold, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnded ? 'Ended On' : 'Ends On',
                style: const TextStyle(
                  color: _ViewColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: _ViewColors.textPrimary,
                  fontSize: 16,
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

// =============================================================================
// FLOATING ACTION DOCK
// =============================================================================

class _FloatingBottomDock extends StatelessWidget {
  final CompetitionEntity competition;
  final bool isOwner;
  final bool isJoined;
  final bool isFull;
  final bool isEnded;
  final bool isLoading;
  final VoidCallback onJoinPressed;
  final VoidCallback onLeavePressed;
  final VoidCallback onOpenDashboardPressed;
  final VoidCallback onManagePressed;
  final VoidCallback onFullPressed;

  const _FloatingBottomDock({
    required this.competition,
    required this.isOwner,
    required this.isJoined,
    required this.isFull,
    required this.isEnded,
    required this.isLoading,
    required this.onJoinPressed,
    required this.onLeavePressed,
    required this.onOpenDashboardPressed,
    required this.onManagePressed,
    required this.onFullPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: _ViewColors.background.withValues(alpha: 0.85),
            border: const Border(
                top: BorderSide(color: _ViewColors.divider, width: 1)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 52,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _ViewColors.primaryGold,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : _buildActions(),
        ),
      ),
    );
  }

  Widget _buildActions() {
    // Priority 1: Handle finished/ended competition
    if (isEnded) {
      return const _PrimaryButton(
        label: 'Competition Ended',
        icon: Icons.lock_clock_rounded,
        isDisabled: true,
      );
    }

    // Priority 2: Owner view
    if (isOwner) {
      return _PrimaryButton(
        label: 'Manage Competition',
        icon: Icons.tune_rounded,
        onPressed: onManagePressed,
      );
    }

    // Priority 3: Joined participant view
    if (isJoined) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrimaryButton(
            label: 'Open Dashboard',
            icon: Icons.play_arrow_rounded,
            onPressed: onOpenDashboardPressed,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onLeavePressed,
            style: TextButton.styleFrom(
              foregroundColor: _ViewColors.error,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'Leave Competition',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      );
    }

    // Priority 4: Non-joined participant view (Full or Joinable)
    return _PrimaryButton(
      label: isFull ? 'Competition Full' : 'Join Competition',
      isDisabled: isFull,
      onPressed: isFull ? onFullPressed : onJoinPressed,
    );
  }
}

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
          backgroundColor:
              isDisabled ? Colors.white12 : _ViewColors.primaryGold,
          foregroundColor: isDisabled ? Colors.white38 : Colors.black,
          elevation: isDisabled ? 0 : 4,
          shadowColor: _ViewColors.primaryGoldGlow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
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
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}