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
    // Re-sync if the competition ID changed or parent passed updated properties
    if (oldWidget.competition.id != widget.competition.id ||
        oldWidget.isJoined != widget.isJoined ||
        oldWidget.competition.participantsCount != widget.competition.participantsCount) {
      _syncStateWithWidget();
    }
  }

  /// Ensures local state strictly reflects parent props and edge cases
  void _syncStateWithWidget() {
    _participantsCount = widget.competition.participantsCount;
    // 🛡️ Guard: If count is 0, user cannot be joined!
    _isJoined = _participantsCount > 0 && widget.isJoined;
  }

  @override
  Widget build(BuildContext context) {
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

          return Card(
            color: AppColors.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _navigateToDetails(context),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Competition Name
                    Text(
                      widget.competition.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.vs,

                    // Description
                    Text(
                      widget.competition.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    12.vs,

                    // Participants count badge
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        6.hs,
                        Text(
                          "$_participantsCount / ${widget.competition.maxParticipants ?? '∞'} Participants",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    16.vs,

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: _buildActionButton(context, isLoading),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isLoading) {
    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        style: _buttonStyle(AppColors.primary),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.background,
          ),
        ),
      );
    }

    // 1. OWNER FLOW
    if (widget.isOwner) {
      return ElevatedButton.icon(
        onPressed: () => _navigateToManage(context),
        icon: const Icon(Icons.settings, size: 18),
        label: const Text("Manage Competition"),
        style: _buttonStyle(AppColors.primary),
      );
    }

    // 2. PARTICIPANT FLOW (Joined)
    if (_isJoined) {
      return ElevatedButton.icon(
        onPressed: () => _navigateToHome(context),
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: const Text("Open Competition"),
        style: _buttonStyle(Colors.blueAccent),
      );
    }

    // 3. NOT JOINED FLOW
    return ElevatedButton.icon(
      onPressed: () => _handleJoin(context),
      icon: const Icon(Icons.login, size: 18),
      label: const Text("Join Competition"),
      style: _buttonStyle(AppColors.primary),
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  void _handleJoin(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showErrorSnackBar(context, "User not authenticated.");
      return;
    }

    if (widget.competition.maxParticipants != null &&
        _participantsCount >= widget.competition.maxParticipants!) {
      _showErrorSnackBar(
        context,
        "Cannot join: Competition has reached maximum participants limit.",
      );
      return;
    }

    if (DateTime.now().isAfter(widget.competition.endDate)) {
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
    final updatedCompetition = await Navigator.push<CompetitionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsView(
          competition: widget.competition,
        ),
      ),
    );

    if (updatedCompetition != null && mounted) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      setState(() {
        _participantsCount = updatedCompetition.participantsCount;
        _isJoined = _participantsCount > 0 && updatedCompetition.isJoinedBy(currentUserId);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionHomeView(
          competition: widget.competition,
        ),
      ),
    );
  }
}