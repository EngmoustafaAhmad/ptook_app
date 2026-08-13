import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/views/competition_details_view.dart';
import 'package:ptook/features/competitions/presintation/views/competition_home_view.dart';
import 'package:ptook/features/competitions/presintation/views/manage_competition_view.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';

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
  late bool _isJoined;
  late int _participantsCount;

  @override
  void initState() {
    super.initState();
    _syncStateWithWidget();
  }

  @override
  void didUpdateWidget(covariant CompetitionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.competition.id != widget.competition.id ||
        oldWidget.isJoined != widget.isJoined ||
        oldWidget.competition.participantsCount !=
            widget.competition.participantsCount) {
      _syncStateWithWidget();
    }
  }

  void _syncStateWithWidget() {
    _participantsCount = widget.competition.participantsCount;
    _isJoined = _participantsCount > 0 && widget.isJoined;
  }

  bool get _isEnded => DateTime.now().isAfter(widget.competition.endDate);

  bool get _isFull {
    if (widget.competition.maxParticipants == null) return false;
    return _participantsCount >= widget.competition.maxParticipants!;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMuted = _isEnded || (_isFull && !widget.isOwner && !_isJoined);

    return BlocProvider(
      create: (context) => sl<JoinCompetitionCubit>(),
      child: BlocConsumer<JoinCompetitionCubit, JoinCompetitionState>(
        listener: (context, state) {
          if (state is JoinCompetitionSuccess) {
            setState(() {
              _isJoined = true;
              _participantsCount++;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            _navigateToHome(context);
          } else if (state is JoinCompetitionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is JoinCompetitionLoading;

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF14161D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
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
                      // Top Row: Icon + Title/Description
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Icon Card
                          _buildLeadingIcon(isMuted),
                          12.hs,

                          // Title and Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.competition.name,
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
                                4.vs,
                                Text(
                                  widget.competition.description,
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
                            ),
                          ),
                        ],
                      ),
                      12.vs,

                      // Bottom Row: Participants Badge & Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Participant Count Pill
                          _buildParticipantsBadge(isMuted),

                          // Action Status Button
                          _buildActionButton(context, isLoading),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Leading Category / Trophy Avatar Icon Box
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
              : (widget.isOwner ? AppColors.primary : const Color(0xFFFFC107)),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (widget.isOwner) return Icons.star_rounded;
    if (_isJoined) return Icons.sports_esports_rounded;
    if (_isEnded) return Icons.flag_rounded;
    return Icons.emoji_events_rounded;
  }

  /// Badge showing current vs max participants
  Widget _buildParticipantsBadge(bool isMuted) {
    final maxPart = widget.competition.maxParticipants;
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
            "$_participantsCount / $maxStr Participants",
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

  /// Multi-state Button Widget
  Widget _buildActionButton(BuildContext context, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 34,
        width: 80,
        child: ElevatedButton(
          onPressed: null,
          style: _buttonStyle(AppColors.primary),
          child: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    // 1. ENDED STATE
    if (_isEnded) {
      return _buildPillButton(
        label: "ENDED",
        backgroundColor: const Color(0xFF222632),
        textColor: Colors.white.withOpacity(0.3),
        onPressed: null,
      );
    }

    // 2. OWNER FLOW
    if (widget.isOwner) {
      return _buildPillButton(
        label: "MANAGE",
        backgroundColor: const Color(0xFF1C1F2A),
        textColor: AppColors.primary,
        borderColor: AppColors.primary,
        onPressed: () => _navigateToManage(context),
      );
    }

    // 3. JOINED FLOW
    if (_isJoined) {
      return _buildPillButton(
        label: "OPEN",
        backgroundColor: const Color(0xFF007AFF),
        textColor: Colors.white,
        onPressed: () => _navigateToHome(context),
      );
    }

    // 4. FULL STATE
    if (_isFull) {
      return _buildPillButton(
        label: "FULL",
        backgroundColor: const Color(0xFF222632),
        textColor: Colors.white.withOpacity(0.3),
        onPressed: null,
      );
    }

    // 5. JOIN FLOW
    return _buildPillButton(
      label: "JOIN",
      backgroundColor: AppColors.primary,
      textColor: Colors.black,
      onPressed: () => _handleJoin(context),
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
          padding: const EdgeInsets.symmetric(horizontal: 22),
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
            fontSize: 12,
            letterSpacing: 0.6,
            color: textColor,
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  void _handleJoin(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showErrorSnackBar(context, "User not authenticated.");
      return;
    }

    if (_isFull) {
      _showErrorSnackBar(
        context,
        "Cannot join: Competition has reached maximum participants limit.",
      );
      return;
    }

    if (_isEnded) {
      _showErrorSnackBar(
        context,
        "Cannot join: Competition has already ended.",
      );
      return;
    }

    context.read<JoinCompetitionCubit>().joinCompetition(
          competitionId: widget.competition.id,
          userId: userId,
        );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _navigateToDetails(BuildContext context) async {
    // جلب ID المستخدم الحالي قبل الانتقال للشاشة
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final updatedCompetition = await Navigator.push<CompetitionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsView(
          competition: widget.competition, 
          currentUserId: currentUserId, // 👈 تم التمرير هنا
          competitionId: widget.competition.id, // 👈 تم تمرير ID المسابقة
        ),
      ),
    );

    if (updatedCompetition != null && mounted) {
      setState(() {
        _participantsCount = updatedCompetition.participantsCount;
        _isJoined =
            _participantsCount > 0 && updatedCompetition.isJoinedBy(currentUserId);
      });
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
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  if (currentUserId.isEmpty) {
    // Optional: Handle unauthenticated edge case
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in first.')),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
          create: (context) => sl<ParticipantCubit>()..fetchParticipants(widget.competition.id),        
          child: CompetitionHomeView(
          competition: widget.competition,
          currentUserId: currentUserId, 
          competitionId:widget.competition.id ,
        ),
      ),
    ),
  );
}
}