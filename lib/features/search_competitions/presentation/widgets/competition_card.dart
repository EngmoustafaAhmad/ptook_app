import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_competition_view.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_details_view.dart' hide AppColors;
import 'package:ptook/features/view_competition/presintation/pages/competition_home_view.dart';

class CompetitionCard extends StatefulWidget {
  final CompetitionEntity competition;
  final bool isOwner;
  final bool isJoined;

  const CompetitionCard({
    super.key,
    required this.competition,
    required this.isOwner,
    this.isJoined = false,
  });

  @override
  State<CompetitionCard> createState() => _CompetitionCardState();
}

class _CompetitionCardState extends State<CompetitionCard> {
  late CompetitionEntity _currentCompetition;
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _syncStateWithWidget(widget.competition, widget.isJoined);
  }

  @override
  void didUpdateWidget(covariant CompetitionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.competition != widget.competition ||
        oldWidget.isJoined != widget.isJoined) {
      _syncStateWithWidget(widget.competition, widget.isJoined);
    }
  }

  void _syncStateWithWidget(CompetitionEntity competition, bool isJoined) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _currentCompetition = competition;
    _isJoined = isJoined ||
        (currentUserId.isNotEmpty &&
            _currentCompetition.participantIds.contains(currentUserId));
  }

  // --- Calculated Domain Properties ---

  bool get _isTeamType => _currentCompetition.type == 'team';

  bool get _isEnded =>
      _currentCompetition.isFinished ||
      DateTime.now().isAfter(_currentCompetition.endDate);

  int? get _effectiveMaxParticipants {
    if (_isTeamType) {
      final teams = _currentCompetition.teams;
      final maxPerTeam = _currentCompetition.maxTeamMembers;
      if (teams != null && maxPerTeam != null) {
        return teams.length * maxPerTeam;
      }
    }
    return _currentCompetition.maxParticipants;
  }

  bool get _isFull {
    final maxLimit = _effectiveMaxParticipants;
    if (maxLimit == null) return false;

    if (_isTeamType) {
      final currentCount = _currentCompetition.teams?.fold<int>(
            0,
            (sum, team) => sum + team.members.length,
          ) ??
          _currentCompetition.participantsCount;
      return currentCount >= maxLimit;
    }

    return _currentCompetition.participantsCount >= maxLimit;
  }

  bool get _isPrivate => !_currentCompetition.isPublic;

  @override
  Widget build(BuildContext context) {
    final bool isMuted = _isEnded || (_isFull && !widget.isOwner && !_isJoined);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<ManageCompetitionCubit>()..initialize(_currentCompetition),
        ),
        BlocProvider(
          create: (_) => sl<ParticipantManagementCubit>()
            ..listenToParticipants(_currentCompetition.id),
        ),
        BlocProvider(
          create: (_) => sl<ViewParticipantsCubit>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
            listener: _onManageCompetitionStateChanged,
          ),
          BlocListener<ParticipantManagementCubit, ParticipantManagementState>(
            listener: _onParticipantManagementStateChanged,
          ),
          BlocListener<ViewParticipantsCubit, ViewParticipantsState>(
            listener: _onViewParticipantsStateChanged,
          ),
        ],
        child: BlocBuilder<ViewParticipantsCubit, ViewParticipantsState>(
          builder: (context, viewParticipantsState) {
            return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
              builder: (context, manageState) {
                final isManageLoading =
                    manageState is ManageCompetitionLoading;
                final isJoinLoading =
                    viewParticipantsState is ViewParticipantsActionLoading;

                return _buildCardContainer(
                  context,
                  isMuted: isMuted,
                  isLoading: isManageLoading || isJoinLoading,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- BLoC State Handlers ---

  void _onManageCompetitionStateChanged(
      BuildContext context, ManageCompetitionState state) {
    if (state is ManageCompetitionLoaded && state.competition != null) {
      _updateLocalCompetition(context, state.competition!);
    } else if (state is ManageCompetitionActionSuccess) {
      _showSnackBar(context, state.message, color: Colors.green);
      if (state.competition != null) {
        _updateLocalCompetition(context, state.competition!);
      }
    } else if (state is ManageCompetitionFinished) {
      _showSnackBar(
        context,
        state.message ?? 'Competition finished successfully',
        color: Colors.orange,
      );
      if (state.competition != null) {
        _updateLocalCompetition(context, state.competition!);
      }
    } else if (state is ManageCompetitionDeleted) {
      _showSnackBar(
        context,
        state.message ?? 'Competition deleted successfully',
        color: Colors.redAccent,
      );
    } else if (state is ManageCompetitionFailure) {
      _showSnackBar(context, state.error, color: Colors.red);
    }
  }

  void _onParticipantManagementStateChanged(
      BuildContext context, ParticipantManagementState state) {
    if (state is ParticipantManagementLoaded) {
      final count = state.participants.length;
      if (count != _currentCompetition.participantsCount) {
        final updatedComp =
            _currentCompetition.copyWith(participantsCount: count);
        _updateLocalCompetition(context, updatedComp);
      }
    } else if (state is ParticipantActionSuccess) {
      _showSnackBar(context, state.message, color: Colors.blueAccent);
    } else if (state is ParticipantManagementFailure) {
      _showSnackBar(context, state.error, color: Colors.red);
    }
  }

  void _onViewParticipantsStateChanged(
      BuildContext context, ViewParticipantsState state) {
    if (state is JoinCompetitionSuccess) {
      _showSnackBar(context, state.message, color: Colors.green);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final updatedCount = _isTeamType
          ? _currentCompetition.participantsCount
          : _currentCompetition.participantsCount + 1;

      final updatedParticipantIds =
          Set<String>.from(_currentCompetition.participantIds)
            ..add(currentUserId);

      final updatedComp = _currentCompetition.copyWith(
        participantsCount: updatedCount,
        participantIds: updatedParticipantIds,
      );
      _updateLocalCompetition(context, updatedComp);
      _navigateToHome(context);
    } else if (state is ViewParticipantsError) {
      _showSnackBar(context, state.message, color: Colors.red);
    }
  }

  // --- UI Structure ---

  Widget _buildCardContainer(
    BuildContext context, {
    required bool isMuted,
    required bool isLoading,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMuted
              ? Colors.white.withOpacity(0.03)
              : (_isPrivate
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeadingIcon(isMuted),
                    12.hs,
                    Expanded(
                      child: _buildCompetitionInfo(isMuted),
                    ),
                  ],
                ),
                12.vs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParticipantsBadge(isMuted),
                    _buildActionButton(context, isLoading),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitionInfo(bool isMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _currentCompetition.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMuted
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isPrivate) ...[
              6.hs,
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: isMuted ? Colors.white24 : Colors.amber.shade400,
              ),
            ],
          ],
        ),
        4.vs,
        Text(
          _currentCompetition.description,
          style: TextStyle(
            fontSize: 12,
            color: isMuted
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.55),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLeadingIcon(bool isMuted) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(12),
        border: widget.isOwner && !isMuted
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1)
            : null,
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 26,
          color: isMuted
              ? Colors.white.withOpacity(0.2)
              : (widget.isOwner
                  ? AppColors.primary
                  : const Color(0xFFFFC107)),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (widget.isOwner) return Icons.star_rounded;
    if (_isJoined) return Icons.sports_esports_rounded;
    if (_isEnded) return Icons.flag_rounded;
    if (_isPrivate) return Icons.lock_outline_rounded;
    return Icons.emoji_events_rounded;
  }

  Widget _buildParticipantsBadge(bool isMuted) {
    final maxPart = _effectiveMaxParticipants;
    final maxStr = maxPart != null ? '$maxPart' : '∞';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 14,
            color: isMuted
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
          ),
          6.hs,
          Text(
            "${_currentCompetition.participantsCount} / $maxStr",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMuted
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        height: 34,
        width: 80,
        child: Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_isEnded) {
      return _buildPillButton(
        label: "ENDED",
        backgroundColor: const Color(0xFF222632),
        textColor: Colors.white.withOpacity(0.3),
        onPressed: null,
      );
    }

    if (widget.isOwner) {
      return _buildPillButton(
        label: "MANAGE",
        backgroundColor: const Color(0xFF1C1F2A),
        textColor: AppColors.primary,
        borderColor: AppColors.primary,
        onPressed: () => _navigateToManage(context),
      );
    }

    if (_isJoined) {
      return _buildPillButton(
        label: "OPEN",
        backgroundColor: const Color(0xFF007AFF),
        textColor: Colors.white,
        onPressed: () => _navigateToHome(context),
      );
    }

    if (_isFull) {
      return _buildPillButton(
        label: "FULL",
        backgroundColor: const Color(0xFF222632),
        textColor: Colors.white.withOpacity(0.3),
        onPressed: null,
      );
    }

    return _buildPillButton(
      label: _isPrivate ? "JOIN PRIVATE" : "JOIN",
      backgroundColor: _isPrivate ? Colors.amber.shade800 : AppColors.primary,
      textColor: Colors.black,
      onPressed: () => _handleJoinAction(context),
    );
  }

  Widget _buildPillButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // --- Actions & Dialogs ---

  void _executeJoinAction(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cubit = context.read<ViewParticipantsCubit>();

    if (_isTeamType) {
      cubit.joinTeamCompetition(
        competitionId: _currentCompetition.id,
        userId: userId,
      );
    } else {
      cubit.joinIndividualCompetition(
        competitionId: _currentCompetition.id,
        userId: userId,
      );
    }
  }

  void _handleJoinAction(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showSnackBar(context, "Please log in first.", color: Colors.orange);
      return;
    }

    if (_isPrivate) {
      _showJoinCodeDialog(context);
    } else {
      _executeJoinAction(context);
    }
  }

  void _showJoinCodeDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => _JoinCodeDialog(
        expectedCode: _currentCompetition.joinCode,
        onSuccess: () => _executeJoinAction(parentContext),
      ),
    );
  }

  void _updateLocalCompetition(
      BuildContext context, CompetitionEntity updated) {
    if (!mounted) return;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() {
      _currentCompetition = updated;
      _isJoined = updated.isJoinedBy(currentUserId);
    });

    try {
      context
          .read<SearchCompetitionCubit>()
          .updateCompetitionInList(updated);
    } catch (_) {}
  }

  void _showSnackBar(BuildContext context, String message,
      {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateToDetails(BuildContext context) async {
    final updatedCompetition = await Navigator.push<CompetitionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsView(
          competition: _currentCompetition,
        ),
      ),
    );

    if (updatedCompetition != null && mounted) {
      _updateLocalCompetition(context, updatedCompetition);
    }
  }

  void _navigateToManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCompetitionView(
          competition: _currentCompetition,
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      _showSnackBar(context, 'Please log in first.', color: Colors.orange);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionHomeView(
          competition: _currentCompetition,
          currentUserId: currentUserId,
          competitionId: _currentCompetition.id,
        ),
      ),
    );
  }
}

// Extracted Dialog Widget for Proper Controller Lifecycle Management
class _JoinCodeDialog extends StatefulWidget {
  final String? expectedCode;
  final VoidCallback onSuccess;

  const _JoinCodeDialog({
    required this.expectedCode,
    required this.onSuccess,
  });

  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  late final TextEditingController _codeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            "Private Competition",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please enter the join code provided by the organizer to access this competition.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            16.vs,
            TextFormField(
              controller: _codeController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Join Code",
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "Enter code here",
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.key, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF14161D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
              validator: (value) {
                final trimmed = value?.trim();
                if (trimmed == null || trimmed.isEmpty) {
                  return "Please enter a join code";
                }
                if (trimmed != widget.expectedCode) {
                  return "Invalid join code. Try again.";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSuccess();
              Navigator.pop(context);
            }
          },
          child: const Text(
            "Enter",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}