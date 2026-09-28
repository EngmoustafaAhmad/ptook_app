import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/theme/app_colors.dart';
import 'package:ptook/core/utils/power_guard.dart'; // ⚡ PowerGuard Utility
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_competition_view.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_home_view.dart';

class CompetitionDetailsView extends StatelessWidget {
  final CompetitionEntity competition;

  const CompetitionDetailsView({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ViewParticipantsCubit>(
      create: (_) => sl<ViewParticipantsCubit>()..listenToParticipants(competition.id),
      child: _CompetitionDetailsContent(initialCompetition: competition),
    );
  }
}

class _CompetitionDetailsContent extends StatefulWidget {
  final CompetitionEntity initialCompetition;

  const _CompetitionDetailsContent({required this.initialCompetition});

  @override
  State<_CompetitionDetailsContent> createState() => _CompetitionDetailsContentState();
}

class _CompetitionDetailsContentState extends State<_CompetitionDetailsContent> {
  late CompetitionEntity _competition;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _competition = widget.initialCompetition;
  }

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isOwner => _competition.ownerId == _currentUserId;
  bool get _isJoined => _competition.isJoinedBy(_currentUserId);
  bool get _isTeamType => _competition.type.toLowerCase() == 'team';
  bool get _isPrivate => !_competition.isPublic;
  bool get _isFull =>
      _competition.maxParticipants != null &&
      _competition.participantsCount >= _competition.maxParticipants!;

  bool get _isEnded {
    final status = _competition.status.toLowerCase();
    final statusEnded = status == 'ended' || status == 'finished' || status == 'completed';
    final dateEnded = DateTime.now().isAfter(_competition.endDate);
    return statusEnded || dateEnded;
  }

  void _handleStateListener(BuildContext context, ViewParticipantsState state) {
    if (state is ViewParticipantsLoaded) {
      final count = state.participants.length;
      final ids = state.participants.map((p) => p.userId).toSet();
      if (count != _competition.participantsCount || ids.length != _competition.participantIds.length) {
        setState(() {
          _competition = _competition.copyWith(
            participantsCount: count,
            participantIds: ids,
          );
        });
      }
    } else if (state is JoinCompetitionSuccess) {
      setState(() {
        _isProcessingAction = false;
        _competition = _competition.copyWith(
          participantIds: {..._competition.participantIds, _currentUserId},
          participantsCount: _competition.participantsCount + 1,
        );
      });
      _showSnackBar(context, state.message, AppColors.success);
      _navigateToHome(context);
    } else if (state is LeaveCompetitionSuccess) {
      setState(() {
        _isProcessingAction = false;
        _competition = _competition.copyWith(
          participantIds: Set.from(_competition.participantIds)..remove(_currentUserId),
          participantsCount: (_competition.participantsCount - 1).clamp(0, 999999),
        );
      });
      _showSnackBar(context, state.message, AppColors.textSecondary);
    } else if (state is ViewParticipantsError) {
      setState(() {
        _isProcessingAction = false;
      });
      _showSnackBar(context, state.message, AppColors.error);
    }
  }

  void _executeJoinAction(BuildContext context) {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    final cubit = context.read<ViewParticipantsCubit>();
    if (_isTeamType) {
      cubit.joinTeamCompetition(
        competitionId: _competition.id,
        userId: _currentUserId,
      );
    } else {
      cubit.joinIndividualCompetition(
        competitionId: _competition.id,
        userId: _currentUserId,
      );
    }
  }

  void _executeLeaveAction(BuildContext context) {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    final cubit = context.read<ViewParticipantsCubit>();
    if (_isTeamType) {
      cubit.leaveTeamCompetition(
        competitionId: _competition.id,
        userId: _currentUserId,
      );
    } else {
      cubit.leaveIndividualCompetition(
        competitionId: _competition.id,
        userId: _currentUserId,
      );
    }
  }

  void _handleJoinAction(BuildContext context) {
    if (_currentUserId.isEmpty) {
      _showSnackBar(context, "Please log in first.", AppColors.primaryGold);
      return;
    }

    // ⚡ Execute Power Guard Check Before Joining
    PowerGuard.executeWithPowerCheck(
      context: context,
      userId: _currentUserId,
      onPowerAvailable: () async {
        if (_isPrivate) {
          _showJoinCodeDialog(context);
        } else {
          _executeJoinAction(context);
        }
      },
    );
  }

  void _showJoinCodeDialog(BuildContext parentContext) {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primaryGold),
              SizedBox(width: 8),
              Text("Private Competition", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please enter the join code provided by the organizer.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Join Code",
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintText: "Enter code here",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    prefixIcon: const Icon(Icons.key, color: AppColors.primaryGold),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGold),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim();
                    if (trimmed == null || trimmed.isEmpty) return "Please enter a join code";
                    if (trimmed != _competition.joinCode) return "Invalid join code. Try again.";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  if (_currentUserId.isNotEmpty) {
                    _executeJoinAction(parentContext);
                  }
                }
              },
              child: const Text("Enter", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onManagePressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCompetitionView(competition: _competition),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted') {
      Navigator.pop(context, 'deleted');
    } else if (result is CompetitionEntity) {
      setState(() => _competition = result);
    }
  }

  void _navigateToHome(BuildContext context) {
    if (_currentUserId.isEmpty) {
      _showSnackBar(context, 'Please log in first.', AppColors.primaryGold);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ViewParticipantsCubit>()..listenToParticipants(_competition.id),
          child: CompetitionHomeView(
            competition: _competition,
            currentUserId: _currentUserId,
            competitionId: _competition.id,
          ),
        ),
      ),
    );
  }

  void _showFullCompetitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.group_off_rounded, color: AppColors.primaryGold, size: 24),
            SizedBox(width: 10),
            Text(
              'Competition Full',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Maximum capacity has been reached. You cannot join this competition at this moment.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
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
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Leave Competition?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to leave this competition? Your rank and progress will be reset.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              _executeLeaveAction(context);
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.pop(context, _competition);
      },
      child: BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
        listener: _handleStateListener,
        builder: (context, state) {
          final isLoading = state is ViewParticipantsLoading ||
              state is ViewParticipantsActionLoading ||
              _isProcessingAction;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context, _competition),
              ),
              title: Text(
                _competition.name.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
              actions: [
                if (_isOwner)
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
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
                        if (_competition.imageUrl != null && _competition.imageUrl!.isNotEmpty) ...[
                          _CompetitionBanner(imageUrl: _competition.imageUrl!),
                          const SizedBox(height: 20),
                        ],
                        _BadgesRow(
                          competition: _competition,
                          isEnded: _isEnded,
                          isTeamType: _isTeamType,
                          isPrivate: _isPrivate,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _competition.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _competition.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.divider, thickness: 1),
                        const SizedBox(height: 24),

                        if (_isTeamType) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  icon: Icons.groups_rounded,
                                  title: 'Max Teams',
                                  value: '${_competition.maxTeams ?? 0}',
                                  unit: 'teams',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  icon: Icons.person_add_alt_1_rounded,
                                  title: 'Members / Team',
                                  value: '${_competition.maxTeamMembers ?? 0}',
                                  unit: 'members',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.stars_rounded,
                                title: 'Total Points',
                                value: '${_competition.totalPoints}',
                                unit: 'pts',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.person_rounded,
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
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _FloatingBottomDock(
                    isOwner: _isOwner,
                    isJoined: _isJoined,
                    isFull: _isFull,
                    isEnded: _isEnded,
                    isPrivate: _isPrivate,
                    isTeamType: _isTeamType,
                    isLoading: isLoading,
                    onJoinPressed: () => _handleJoinAction(context),
                    onLeavePressed: () => _showLeaveDialog(context),
                    onOpenDashboardPressed: () => _navigateToHome(context),
                    onManagePressed: _onManagePressed,
                    onFullPressed: () => _showFullCompetitionDialog(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final CompetitionEntity competition;
  final bool isEnded;
  final bool isTeamType;
  final bool isPrivate;

  const _BadgesRow({
    required this.competition,
    required this.isEnded,
    required this.isTeamType,
    required this.isPrivate,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = competition.status.toLowerCase() == 'active' && !isEnded;
    final statusColor = isEnded ? AppColors.error : (isLive ? AppColors.success : Colors.amber);
    final statusText = isEnded ? 'ENDED' : (isLive ? 'LIVE' : competition.status.toUpperCase());

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _BadgePill(
          label: competition.category.toUpperCase(),
          borderColor: AppColors.primaryGold.withOpacity(0.6),
          textColor: AppColors.primaryGold,
        ),
        _BadgePill(
          label: isTeamType ? 'TEAM' : 'INDIVIDUAL',
          borderColor: AppColors.textSecondary.withOpacity(0.3),
          textColor: AppColors.textPrimary,
        ),
        _BadgePill(
          label: isPrivate ? 'PRIVATE' : 'PUBLIC',
          borderColor: isPrivate ? Colors.amber.withOpacity(0.6) : AppColors.accentBlue.withOpacity(0.6),
          textColor: isPrivate ? Colors.amber : AppColors.accentBlue,
        ),
        _BadgePill(
          label: statusText,
          backgroundColor: statusColor.withOpacity(0.15),
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
        color: backgroundColor ?? Colors.white.withOpacity(0.04),
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final double? progress;

  const _MetricCard({
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryGold, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
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
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
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

  const _TimelineCard({required this.endDate, required this.isEnded});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${endDate.day} ${_months[endDate.month - 1]}, ${endDate.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnded ? 'Ended On' : 'Ends On',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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

class _FloatingBottomDock extends StatelessWidget {
  final bool isOwner;
  final bool isJoined;
  final bool isFull;
  final bool isEnded;
  final bool isPrivate;
  final bool isTeamType;
  final bool isLoading;
  final VoidCallback onJoinPressed;
  final VoidCallback onLeavePressed;
  final VoidCallback onOpenDashboardPressed;
  final VoidCallback onManagePressed;
  final VoidCallback onFullPressed;

  const _FloatingBottomDock({
    required this.isOwner,
    required this.isJoined,
    required this.isFull,
    required this.isEnded,
    required this.isPrivate,
    required this.isTeamType,
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
            color: AppColors.background.withOpacity(0.85),
            border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 52,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
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
    if (isEnded) {
      return const _ActionButton(
        label: 'Competition Ended',
        icon: Icons.lock_clock_rounded,
        isDisabled: true,
      );
    }

    if (isOwner) {
      return _ActionButton(
        label: 'Manage Competition',
        icon: Icons.tune_rounded,
        onPressed: onManagePressed,
      );
    }

    if (isJoined) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            label: 'Open Dashboard',
            icon: Icons.play_arrow_rounded,
            backgroundColor: AppColors.accentBlue,
            textColor: Colors.white,
            onPressed: onOpenDashboardPressed,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onLeavePressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
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

    return _ActionButton(
      label: isFull ? 'Competition Full' : (isPrivate ? 'Join Private' : 'Join Competition'),
      isDisabled: isFull,
      backgroundColor: isPrivate ? Colors.amber.shade800 : AppColors.primaryGold,
      textColor: isPrivate ? Colors.white : Colors.black,
      onPressed: isFull ? onFullPressed : onJoinPressed,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;

  const _ActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDisabled ? Colors.white12 : (backgroundColor ?? AppColors.primaryGold);
    final fg = isDisabled ? Colors.white38 : (textColor ?? Colors.black);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isDisabled ? 0 : 4,
          shadowColor: AppColors.primaryGoldGlow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}