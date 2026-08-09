import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/join_competition_state.dart';

class LeaveBottomBar extends StatelessWidget {
  final CompetitionEntity competition;
  final VoidCallback onLeft;

  const LeaveBottomBar({
    super.key, 
    required this.competition,
    required this.onLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: BlocConsumer<JoinCompetitionCubit, JoinCompetitionState>(
        listener: (context, state) {
          if (state is LeaveCompetitionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            onLeft();
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

          return SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => _handleLeave(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.redAccent,
                      ),
                    )
                  : const Text(
                      "Leave Competition",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _handleLeave(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    context.read<JoinCompetitionCubit>().leaveCompetition(
          competitionId: competition.id,
          userId: userId,
        );
  }
}