// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';

class TeamOverviewTabView extends StatelessWidget {
  const TeamOverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
      builder: (context, state) {
        final competition = state.competition;

        // Safely retrieve and sort teams descending by total points
        final rawTeams = List<TeamEntity>.from(competition?.teams ?? []);
        rawTeams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        final totalTeams = rawTeams.length;

        // Calculate total participants dynamically across all teams for real-time accuracy
        final calculatedParticipants = rawTeams.fold<int>(
          0,
          (sum, team) => sum + team.members.length,
        );
        final totalParticipants = calculatedParticipants > 0
            ? calculatedParticipants
            : state.totalParticipants;

        // Lifecycle Status Evaluation
        final now = DateTime.now();
        final isEndedByDate =
            competition != null && now.isAfter(competition.endDate);
        final isEndedByStatus = competition?.status.toLowerCase() == 'ended';
        final isEnded = state.isFinished || isEndedByDate || isEndedByStatus;

        // Calculate dynamic duration in days
        final durationInDays = competition != null
            ? competition.endDate.difference(competition.startDate).inDays
            : 0;
        final displayDuration = durationInDays >= 0 ? durationInDays : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-Time Stats Header Row
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
                    label: 'Participants',
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

              // Conditional Section: Ended vs Active Real-Time Phase
              if (isEnded) ...[
                const Text(
                  'Final Leaderboard',
                  style: TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (rawTeams.isEmpty)
                  const _EmptyTeamsState()
                else ...[
                  _PodiumView(topThree: rawTeams.take(3).toList()),
                  const SizedBox(height: 24),
                  if (rawTeams.length > 3) ...[
                    const Text(
                      'Runner-up Teams',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rawTeams.length - 3,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final team = rawTeams[index + 3];
                        return _RunnerUpCard(team: team, rank: index + 4);
                      },
                    ),
                  ],
                ],
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Participating Teams',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (totalTeams > 0)
                      Text(
                        '$totalTeams Registered',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (rawTeams.isEmpty)
                  const _EmptyTeamsState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rawTeams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final team = rawTeams[index];
                      final targetPoints = competition?.totalPoints ?? 1;
                      final progress = targetPoints > 0
                          ? (team.totalPoints / targetPoints).clamp(0.0, 1.0)
                          : 0.0;

                      return _TeamRankCard(
                        rank: '${index + 1}',
                        badgeColor: _getBadgeColor(index),
                        team: team,
                        progress: progress,
                      );
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getBadgeColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFC107);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white24;
    }
  }
}

// Stats Metric Item
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

// Empty Roster Indicator
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
            'Teams will appear here once created or joined.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Podium Top 3 View Component
class _PodiumView extends StatelessWidget {
  final List<TeamEntity> topThree;

  const _PodiumView({required this.topThree});

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
                    avatarRadius: 55,
                  )
                : const SizedBox(),
          ),
          Expanded(
            child: first != null
                ? _PodiumColumn(
                    team: first,
                    rank: 1,
                    color: const Color(0xFFFFC107),
                    avatarRadius: 75,
                  )
                : const SizedBox(),
          ),
          Expanded(
            child: third != null
                ? _PodiumColumn(
                    team: third,
                    rank: 3,
                    color: const Color(0xFFCD7F32),
                    avatarRadius: 50,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

// Podium Column Unit
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
                radius: avatarRadius / 2,
                backgroundColor: Colors.white12,
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$rank',
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

// Runner-Up List Item Card with Real-time Participant Info
class _RunnerUpCard extends StatelessWidget {
  final TeamEntity team;
  final int rank;

  const _RunnerUpCard({
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
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11),
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

// Active Team Rank Item Card with Real-time Participant Display
class _TeamRankCard extends StatefulWidget {
  final String rank;
  final Color badgeColor;
  final TeamEntity team;
  final double progress;

  const _TeamRankCard({
    required this.rank,
    required this.badgeColor,
    required this.team,
    required this.progress,
  });

  @override
  State<_TeamRankCard> createState() => _TeamRankCardState();
}

class _TeamRankCardState extends State<_TeamRankCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161925),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExpanded ? const Color(0xFFFFC107) : Colors.white12,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white12,
                child: Text(
                  widget.team.name.isNotEmpty
                      ? widget.team.name[0].toUpperCase()
                      : 'T',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.team.members.length} Members',
                style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.team.totalPoints} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  color: const Color(0xFFFFC107),
                  backgroundColor: Colors.white10,
                  minHeight: 6,
                ),
              ),

              // Real-Time Participants Avatar Stack
              if (widget.team.members.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ParticipantAvatarStack(members: widget.team.members),
              ],

              // Toggle Participant Details Button
              if (widget.team.members.isNotEmpty) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? 'Hide Participants' : 'View Participants',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],

              // Expanded Participant List View
              if (_isExpanded && widget.team.members.isNotEmpty) ...[
                const Divider(color: Colors.white12, height: 16),
                Column(
                  children: widget.team.members.map((member) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                const Color(0xFFFFC107).withOpacity(0.2),
                            child: Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        // Rank Badge
        CircleAvatar(
          radius: 12,
          backgroundColor: widget.badgeColor,
          child: Text(
            widget.rank,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}


class _ParticipantAvatarStack extends StatelessWidget {
  final List members;

  const _ParticipantAvatarStack({
    required this.members,
  });

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

  String _getInitial(dynamic member) {
    try {
      final name = member.name as String?;
      if (name != null && name.trim().isNotEmpty) {
        return name.trim()[0].toUpperCase();
      }
    } catch (_) {
      // Fallback if property access fails
    }
    return '?';
  }
}