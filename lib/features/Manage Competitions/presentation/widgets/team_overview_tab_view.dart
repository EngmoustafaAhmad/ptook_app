import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class TeamOverviewTabView extends StatefulWidget {
  const TeamOverviewTabView({super.key});

  @override
  State<TeamOverviewTabView> createState() => _TeamOverviewTabViewState();
}

class _TeamOverviewTabViewState extends State<TeamOverviewTabView> {
  bool _showAllRunnersUp = false;

  @override
  Widget build(BuildContext context) {
    final competition = context.select(
      (ManageCompetitionCubit cubit) => cubit.state.competition,
    );
    final teams = context.select(
      (TeamManagementCubit cubit) => cubit.state.teams,
    );

    // Calculate metrics
    final durationInDays = competition != null
        ? competition.endDate.difference(competition.startDate).inDays
        : 0;
    final displayDuration = durationInDays >= 0 ? durationInDays : 0;

    final sortedTeams = List<TeamEntity>.from(teams)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final totalTeams = sortedTeams.length;
    final totalParticipants = sortedTeams.fold<int>(
      0,
      (sum, team) => sum + team.members.length,
    );

    final topThree = sortedTeams.take(3).toList();
    final runnersUp = sortedTeams.length > 3 ? sortedTeams.sublist(3) : <TeamEntity>[];
    final displayedRunnersUp =
        _showAllRunnersUp ? runnersUp : runnersUp.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            const Text(
              'Top Teams',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _PodiumView(topThree: topThree),

            if (runnersUp.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Runner-up Teams',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${runnersUp.length} Teams',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedRunnersUp.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final team = displayedRunnersUp[index];
                  return _RunnerUpCard(
                    key: ValueKey(team.id),
                    team: team,
                    rank: index + 4,
                  );
                },
              ),

              if (runnersUp.length > 3) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAllRunnersUp = !_showAllRunnersUp;
                      });
                    },
                    icon: Icon(
                      _showAllRunnersUp
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFFFFC107),
                    ),
                    label: Text(
                      _showAllRunnersUp
                          ? 'Show Less'
                          : 'Show More (${runnersUp.length - 3} more)',
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
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

class _PodiumView extends StatelessWidget {
  final List<TeamEntity> topThree;

  const _PodiumView({required this.topThree});

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second != null
                ? _PodiumColumn(
                    team: second,
                    rank: 2,
                    color: const Color(0xFFC0C0C0),
                    avatarRadius: 26,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: first != null
                ? _PodiumColumn(
                    team: first,
                    rank: 1,
                    color: const Color(0xFFFFC107),
                    avatarRadius: 34,
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: third != null
                ? _PodiumColumn(
                    team: third,
                    rank: 3,
                    color: const Color(0xFFCD7F32),
                    avatarRadius: 24,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final TeamEntity team;
  final int rank;
  final Color color;
  final double avatarRadius;

  const _PodiumColumn({
    required this.team,
    required this.rank,
    required this.color,
    required this.avatarRadius,
  });

  @override
  Widget build(BuildContext context) {
    final initial = team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T';

    return Column(
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
                border: Border.all(color: color, width: rank == 1 ? 3 : 2),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.white12,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rank == 1 ? 20 : 16,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
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
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${team.members.length} members',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

class _RunnerUpCard extends StatelessWidget {
  final TeamEntity team;
  final int rank;

  const _RunnerUpCard({
    super.key,
    required this.team,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${team.members.length} Members',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '${team.totalPoints} pts',
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (team.members.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ParticipantAvatarStack(members: team.members),
          ],
        ],
      ),
    );
  }
}

class _ParticipantAvatarStack extends StatelessWidget {
  final List<ParticipantEntity> members;

  const _ParticipantAvatarStack({required this.members});

  @override
  Widget build(BuildContext context) {
    final displayMembers = members.take(5).toList();
    final remainingCount = members.length - displayMembers.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < displayMembers.length; i++)
              Align(
                widthFactor: i == 0 ? 1.0 : 0.7,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF161925),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFFFC107).withOpacity(0.3),
                    child: Text(
                      _getInitial(displayMembers[i]),
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (remainingCount > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$remainingCount more',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ],
    );
  }

  String _getInitial(ParticipantEntity member) {
    final name = member.name.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}