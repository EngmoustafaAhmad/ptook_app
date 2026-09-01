import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_state.dart';
import 'package:ptook/features/view_competition/presintation/widgets/participant_tile.dart';

class CompetitionParticipantsViewAll extends StatefulWidget {
  final String competitionId;
  final String? currentUserId;

  const CompetitionParticipantsViewAll({
    super.key,
    required this.competitionId,
    this.currentUserId,
  });

  @override
  State<CompetitionParticipantsViewAll> createState() => _CompetitionParticipantsViewAllState();
}

class _CompetitionParticipantsViewAllState extends State<CompetitionParticipantsViewAll> {
  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  void _fetchParticipants() {
    context.read<ViewParticipantsCubit>().listenToParticipants(widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
             Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'PARTICIPANTS',
          style: TextStyle(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocConsumer<ViewParticipantsCubit, ViewParticipantsState>(
        listener: (context, state) {
          if (state is ViewParticipantsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ViewParticipantsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 2.5,
              ),
            );
          }

          if (state is ViewParticipantsError) {
            return _ErrorStateWidget(
              message: state.message,
              onRetry: _fetchParticipants,
            );
          }

          if (state is ViewParticipantsLoaded) {
            if (state.participants.isEmpty) {
              return _EmptyStateWidget(onRefresh: _fetchParticipants);
            }

            return RefreshIndicator(
              color: AppColors.primaryGold,
              backgroundColor: AppColors.cardBackground,
              onRefresh: () async => _fetchParticipants(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                itemCount: state.participants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return ParticipantTile(
                    participant: state.participants[index],
                    rank: index + 1,
                    currentUserId: widget.currentUserId,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyStateWidget({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Participants Yet',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first one to join this competition!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryGold),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}