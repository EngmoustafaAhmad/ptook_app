import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/team_members_screen.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class CustomTopTeamsWidget extends StatelessWidget {
  final List<TeamEntity> teams;
  final CompetitionEntity competition;
  final VoidCallback? onViewAllPressed;
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  const CustomTopTeamsWidget({
    super.key,
    required this.teams,
    required this.competition,
    required this.onShowConfirmDialog,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const SizedBox.shrink();

    final sortedTeams = List<TeamEntity>.from(teams)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final topThree = sortedTeams.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Teams',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onViewAllPressed != null)
              TextButton(
                onPressed: onViewAllPressed,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _TopTeamsPodiumCard(
          topThree: topThree,
          competition: competition,
          onShowConfirmDialog: onShowConfirmDialog,
        ),
      ],
    );
  }
}

class _TopTeamsPodiumCard extends StatelessWidget {
  final List<TeamEntity> topThree;
  final CompetitionEntity competition;
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  const _TopTeamsPodiumCard({
    required this.topThree,
    required this.competition,
    required this.onShowConfirmDialog,
  });

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second != null
                ? _PodiumItem(
                    team: second,
                    rank: 2,
                    badgeColor: const Color(0xFFC0C0C0),
                    avatarRadius: 26,
                    competition: competition,
                    onShowConfirmDialog: onShowConfirmDialog,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: first != null
                ? _PodiumItem(
                    team: first,
                    rank: 1,
                    badgeColor: const Color(0xFFFFC107),
                    avatarRadius: 34,
                    competition: competition,
                    onShowConfirmDialog: onShowConfirmDialog,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: third != null
                ? _PodiumItem(
                    team: third,
                    rank: 3,
                    badgeColor: const Color(0xFFCD7F32),
                    avatarRadius: 24,
                    competition: competition,
                    onShowConfirmDialog: onShowConfirmDialog,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final TeamEntity team;
  final int rank;
  final Color badgeColor;
  final double avatarRadius;
  final CompetitionEntity competition;
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  const _PodiumItem({
    required this.team,
    required this.rank,
    required this.badgeColor,
    required this.avatarRadius,
    required this.competition,
    required this.onShowConfirmDialog,
  });

  @override
  Widget build(BuildContext context) {
    final initial = team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T';
    final hasAvatar = team.avatarUrl != null && team.avatarUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        final participantCubit = context.read<ParticipantManagementCubit>();
        participantCubit.listenToParticipants(competition.id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<TeamManagementCubit>()),
                BlocProvider.value(value: participantCubit),
              ],
              child: TeamMembersScreen(
                team: team,
                competitionId: competition.id,
                isFinished: competition.isFinished,
                onShowConfirmDialog: onShowConfirmDialog,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor, width: rank == 1 ? 3 : 2),
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white12,
                  backgroundImage: hasAvatar
                      ? CachedNetworkImageProvider(team.avatarUrl!)
                      : null,
                  child: !hasAvatar
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: rank == 1 ? 20 : 16,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                top: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '${team.totalPoints} pts',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${team.members.length} members',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}