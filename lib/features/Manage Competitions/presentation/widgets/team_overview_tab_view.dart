import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';
import 'package:ptook/features/shared/presintation/widgets/custome_top_teams_widget.dart';

class TeamOverviewTabView extends StatefulWidget {
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  })? onShowConfirmDialog;

  const TeamOverviewTabView({
    super.key,
    this.onShowConfirmDialog,
  });

  @override
  State<TeamOverviewTabView> createState() => _TeamOverviewTabViewState();
}

class _TeamOverviewTabViewState extends State<TeamOverviewTabView> {

  @override
  Widget build(BuildContext context) {
    final competition = context.select(
      (ManageCompetitionCubit cubit) => cubit.state.competition,
    );
    final teams = context.select(
      (TeamManagementCubit cubit) => cubit.state.teams,
    );

    if (competition == null) {
      return const SizedBox.shrink();
    }

    // Calculate metrics
    final durationInDays = competition.endDate.difference(competition.startDate).inDays;
    final displayDuration = durationInDays >= 0 ? durationInDays : 0;

    final sortedTeams = List<TeamEntity>.from(teams)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final totalTeams = sortedTeams.length;
    final totalParticipants = sortedTeams.fold<int>(
      0,
      (sum, team) => sum + team.members.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Stat Cards ──────────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                value: '$totalTeams',
                label: 'Teams',
                icon: Icons.groups_outlined,
              ),
              const SizedBox(width: 8),
              _StatCard(
                value: '$totalParticipants',
                label: 'Members',
                icon: Icons.person_outline,
              ),
              const SizedBox(width: 8),
              _StatCard(
                value: '$displayDuration',
                label: 'Days\nDuration',
                icon: Icons.access_time,
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (sortedTeams.isEmpty)
            const _EmptyTeamsState()
          else ...[
            // ─── Custom Top Teams Component (Podium + Header View All) ───────
            CustomTopTeamsWidget(
              teams: sortedTeams,
              competition: competition,
              onShowConfirmDialog: widget.onShowConfirmDialog ??
                  ({
                    required context,
                    required title,
                    required content,
                    required confirmText,
                    required onConfirm,
                    confirmColor,
                  }) {},
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161925),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFC107), size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTeamsState extends StatelessWidget {
  const _EmptyTeamsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.groups_outlined, color: Colors.white38, size: 48),
          SizedBox(height: 12),
          Text(
            'No Teams Joined Yet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Teams will appear here once participating.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

