import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/core/utils/power_guard.dart'; // ⚡ PowerGuard Utility
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_competition_view.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_details_view.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_home_view.dart';

class CompetitionCard extends StatefulWidget {
  final CompetitionEntity competition;
  final String currentUserId;

  const CompetitionCard({
    super.key,
    required this.competition,
    required this.currentUserId,
  });

  @override
  State<CompetitionCard> createState() => _CompetitionCardState();
}

class _CompetitionCardState extends State<CompetitionCard> {
  late final ViewParticipantsCubit _participantsCubit;

  @override
  void initState() {
    super.initState();
    _participantsCubit = sl<ViewParticipantsCubit>()
      ..listenToParticipants(widget.competition.id);
  }

  @override
  void dispose() {
    _participantsCubit.close();
    super.dispose();
  }

  // --- Pure Computed Domain Properties ---

  bool get _isOwner =>
      widget.currentUserId.isNotEmpty &&
      widget.competition.ownerId == widget.currentUserId;

  bool get _isJoined => widget.competition.isJoinedBy(widget.currentUserId);

  bool get _isTeamType => widget.competition.type == 'team';

  bool get _isEnded =>
      widget.competition.isFinished ||
      DateTime.now().isAfter(widget.competition.endDate);

  int? get _effectiveMaxParticipants {
    if (_isTeamType) {
      final maxTeams = widget.competition.maxTeams;
      final maxPerTeam = widget.competition.maxTeamMembers;
      if (maxTeams != null && maxPerTeam != null) {
        return maxTeams * maxPerTeam;
      }
    }
    return widget.competition.maxParticipants;
  }

  bool get _isFull {
    final maxLimit = _effectiveMaxParticipants;
    if (maxLimit == null) return false;
    return widget.competition.participantsCount >= maxLimit;
  }

  bool get _isPrivate => !widget.competition.isPublic;

  @override
  Widget build(BuildContext context) {
    final bool isMuted = _isEnded || (_isFull && !_isOwner && !_isJoined);

    return BlocProvider<ViewParticipantsCubit>.value(
      value: _participantsCubit,
      child: BlocListener<ViewParticipantsCubit, ViewParticipantsState>(
        listenWhen: (previous, current) =>
            current is JoinCompetitionSuccess || current is ViewParticipantsError,
        listener: (context, state) {
          if (state is JoinCompetitionSuccess) {
            _showSnackBar(context, state.message, color: Colors.green);
            _navigateToHome(context);
          } else if (state is ViewParticipantsError) {
            _showSnackBar(context, state.message, color: Colors.red);
          }
        },
        child: BlocBuilder<ViewParticipantsCubit, ViewParticipantsState>(
          builder: (context, state) {
            final isLoading = state is ViewParticipantsActionLoading;

            return Container(
              height: 120,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF14161D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMuted
                      ? Colors.white.withValues(alpha: 0.03)
                      : (_isPrivate
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToDetails(context),
                  child: Row(
                    children: [
                      // 1. Left Thumbnail
                      _buildThumbnail(isMuted),

                      // 2. Middle Content Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCompetitionInfo(isMuted),
                              4.vs,
                              _buildOwnerHeader(isMuted),
                              8.vs,
                              _buildParticipantsBadge(isMuted),
                            ],
                          ),
                        ),
                      ),

                      // 3. Right Action Column
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(context, isLoading),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Compact Components ---

  Widget _buildThumbnail(bool isMuted) {
    final String? imageUrl = widget.competition.imageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return SizedBox(
      width: 100,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            ColorFiltered(
              colorFilter: isMuted
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
                errorBuilder: (_, _, _) => _buildFallbackHeader(isMuted),
              ),
            )
          else
            _buildFallbackHeader(isMuted),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Positioned(
            top: 6,
            left: 6,
            child: Row(
              children: [
                if (_isPrivate) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                  4.hs,
                ],
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14161D).withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    size: 10,
                    color: isMuted
                        ? Colors.white38
                        : (_isOwner
                            ? AppColors.primary
                            : const Color(0xFFFFC107)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHeader(bool isMuted) {
    return Container(
      color: const Color(0xFF1C1F2A),
      child: Center(
        child: Icon(
          Icons.workspace_premium_rounded,
          size: 28,
          color: isMuted ? Colors.white24 : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildOwnerHeader(bool isMuted) {
    final ownerName = widget.competition.displayOwnerName;
    final ownerAvatar = widget.competition.displayOwnerAvatarUrl;
    final hasAvatar = ownerAvatar != null && ownerAvatar.trim().isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          backgroundImage: hasAvatar
              ? CachedNetworkImageProvider(ownerAvatar)
              : null,
          child: !hasAvatar
              ? Text(
                  ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'O',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isMuted ? Colors.white38 : AppColors.primary,
                  ),
                )
              : null,
        ),
        6.hs,
        Expanded(
          child: Text(
            ownerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isMuted
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionInfo(bool isMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.competition.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isMuted ? Colors.white.withValues(alpha: 0.4) : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        2.vs,
        Text(
          widget.competition.description,
          style: TextStyle(
            fontSize: 11,
            color: isMuted
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.5),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _getCategoryIcon() {
    if (_isOwner) return Icons.star_rounded;
    if (_isJoined) return Icons.sports_esports_rounded;
    if (_isEnded) return Icons.flag_rounded;
    if (_isPrivate) return Icons.lock_outline_rounded;
    return Icons.emoji_events_rounded;
  }

  Widget _buildParticipantsBadge(bool isMuted) {
    final maxPart = _effectiveMaxParticipants;
    final maxStr = maxPart != null ? '$maxPart' : '∞';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_outline_rounded,
          size: 12,
          color: isMuted
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
        ),
        4.hs,
        Text(
          "${widget.competition.participantsCount} / $maxStr",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isMuted
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        height: 30,
        width: 70,
        child: Center(
          child: SizedBox(
            height: 14,
            width: 14,
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
        textColor: Colors.white.withValues(alpha: 0.3),
        onPressed: null,
      );
    }

    if (_isOwner) {
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
        textColor: Colors.white.withValues(alpha: 0.3),
        onPressed: null,
      );
    }

    return _buildPillButton(
      label: _isPrivate ? "JOIN" : "JOIN",
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
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.2)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 0.3,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // --- Actions & Navigation ---

  void _executeJoinAction(BuildContext context) {
    if (widget.currentUserId.isEmpty) return;

    if (_isTeamType) {
      _participantsCubit.joinTeamCompetition(
        competitionId: widget.competition.id,
        userId: widget.currentUserId,
      );
    } else {
      _participantsCubit.joinIndividualCompetition(
        competitionId: widget.competition.id,
        userId: widget.currentUserId,
      );
    }
  }

  void _handleJoinAction(BuildContext context) {
    if (widget.currentUserId.isEmpty) {
      _showSnackBar(context, "Please log in first.", color: Colors.orange);
      return;
    }

    // ⚡ Wrap joining action inside PowerGuard cycle check
    PowerGuard.executeWithPowerCheck(
      context: context,
      userId: widget.currentUserId,
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
    showDialog(
      context: parentContext,
      builder: (_) => _JoinCodeDialog(
        expectedCode: widget.competition.joinCode,
        onSuccess: () => _executeJoinAction(parentContext),
      ),
    );
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
          competition: widget.competition,
        ),
      ),
    );

    if (updatedCompetition != null && context.mounted) {
      context
          .read<SearchCompetitionCubit>()
          .updateCompetitionInList(updatedCompetition);
    }
  }

  void _navigateToManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCompetitionView(
          competition: widget.competition,
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    if (widget.currentUserId.isEmpty) {
      _showSnackBar(context, 'Please log in first.', color: Colors.orange);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionHomeView(
          competition: widget.competition,
          currentUserId: widget.currentUserId,
          competitionId: widget.competition.id,
        ),
      ),
    );
  }
}

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
                    TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: const Icon(Icons.key, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF14161D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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