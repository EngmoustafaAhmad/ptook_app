import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_state.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class TeamMembersScreen extends StatefulWidget {
  final TeamEntity team;
  final String competitionId;
  final bool isFinished;
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  const TeamMembersScreen({
    super.key,
    required this.team,
    required this.competitionId,
    required this.isFinished,
    required this.onShowConfirmDialog,
  });

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize active streaming for competition participants
    context
        .read<ParticipantManagementCubit>()
        .listenToParticipants(widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: Text('${widget.team.name} Members'),
        backgroundColor: const Color(0xFF161925),
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TeamManagementCubit, TeamManagementState>(
            listener: (context, state) {
              if (state is TeamActionSuccess) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is TeamManagementFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
              }
            },
          ),
        ],
        child: BlocBuilder<ParticipantManagementCubit, ParticipantManagementState>(
          builder: (context, participantState) {
            return BlocBuilder<TeamManagementCubit, TeamManagementState>(
              builder: (context, teamState) {
                // Get updated team reference from state or initial property
                final currentTeam = teamState.teams.firstWhere(
                  (t) => t.id == widget.team.id,
                  orElse: () => widget.team,
                );

                // Reconcile streamed participants with the active team member list
                final teamMemberIds = currentTeam.members.map((m) => m.id).toSet();
                
                final teamMembers = participantState.participants
                    .where((p) => teamMemberIds.contains(p.id) || p.teamId == currentTeam.id)
                    .toList()
                  ..sort((a, b) => b.points.compareTo(a.points));

                if (teamMembers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No members in this team.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: teamMembers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];

                    return MemberTile(
                      key: ValueKey(member.id),
                      member: member,
                      rank: index + 1,
                      isFinished: widget.isFinished,
                      onUpdatePoints: (addedPoints) {
                        context
                            .read<TeamManagementCubit>()
                            .updateTeamParticipantPoints(
                              competitionId: widget.competitionId,
                              teamId: currentTeam.id,
                              participantId: member.id,
                              addedPoints: addedPoints,
                            );
                      },
                      onRemoveMember: () {
                        widget.onShowConfirmDialog(
                          context: context,
                          title: 'Remove Member',
                          content: 'Are you sure you want to remove "${member.name}"?',
                          confirmText: 'Remove',
                          confirmColor: Colors.redAccent,
                          onConfirm: () async {
                            // 1. Store cubit reference before popping context
                            final teamCubit = context.read<TeamManagementCubit>();
                            
                            try {
                              await teamCubit.removeTeamParticipant(
                                competitionId: widget.competitionId,
                                teamId: currentTeam.id,
                                participantId: member.id,
                              );
                            } catch (e) {
                              debugPrint('Error removing member: $e');
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MemberTile extends StatelessWidget {
  final ParticipantEntity member;
  final int rank;
  final bool isFinished;
  final ValueChanged<int> onUpdatePoints;
  final VoidCallback onRemoveMember;

  const MemberTile({
    super.key,
    required this.member,
    required this.rank,
    required this.isFinished,
    required this.onUpdatePoints,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final String name = member.name;
    final int points = member.points;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white12,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isFinished) ...[
            _PointsStepper(
              onSubmit: onUpdatePoints,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
              onPressed: onRemoveMember,
            ),
          ],
        ],
      ),
    );
  }
}

class _PointsStepper extends StatefulWidget {
  final ValueChanged<int> onSubmit;

  const _PointsStepper({required this.onSubmit});

  @override
  State<_PointsStepper> createState() => _PointsStepperState();
}

class _PointsStepperState extends State<_PointsStepper> {
  int _pointDelta = 1;

  void _decrement() {
    if (_pointDelta > 1) {
      setState(() => _pointDelta--);
    }
  }

  void _increment() {
    setState(() => _pointDelta++);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
            onPressed: _decrement,
          ),
          Text(
            '$_pointDelta',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, color: Colors.white70, size: 16),
            onPressed: _increment,
          ),
          InkWell(
            onTap: () => widget.onSubmit(_pointDelta),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}