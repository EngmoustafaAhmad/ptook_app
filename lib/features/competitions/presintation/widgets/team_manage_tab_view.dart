import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

class TeamManageTabView extends StatelessWidget {
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  final CompetitionEntity competition;

  const TeamManageTabView({
    super.key,
    required this.onShowConfirmDialog,
    required this.competition,
  });

  void _showCreateTeamDialog(BuildContext context, List<TeamEntity> existingTeams) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CreateTeamDialog(
        existingTeams: existingTeams,
        onSubmit: (teamName, isPrivate, joinCode) {
          context.read<ManageCompetitionCubit>().createTeam(
                teamName: teamName,
                isPrivate: isPrivate,
                joinCode: joinCode,
              );
        },
      ),
    );
  }

  String _formatPoints(num points) {
    if (points >= 1000) {
      final double k = points / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return points.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
      builder: (context, state) {
        final rankedTeams = state.rankedTeams;
        final topThree = rankedTeams.take(3).toList();
        final remainingTeams = rankedTeams;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Teams Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: state.isFinished
                        ? null
                        : () => _showCreateTeamDialog(context, rankedTeams),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black, size: 18),
                    label: const Text(
                      'Create Team',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Leaderboard Top 3 Card List
              if (rankedTeams.isNotEmpty) ...[
                _buildLeaderboardPodium(topThree),
                const SizedBox(height: 20),
              ],

              // Empty State
              if (rankedTeams.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161925),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Center(
                    child: Text(
                      'No teams available. Tap "Create Team" to add one.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                )
              else ...[
                // Team Accordion List
                ...remainingTeams.map((team) {
                  final isExpanded = state.expandedTeamId == team.id;
                  final teamRank = rankedTeams.indexOf(team) + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TeamCard(
                      team: team,
                      rank: teamRank,
                      isExpanded: isExpanded,
                      isFinished: state.isFinished,
                      onToggleExpand: () {
                        context.read<ManageCompetitionCubit>().toggleExpandTeam(team.id);
                      },
                      onDeleteTeam: () {
                        onShowConfirmDialog(
                          context: context,
                          title: 'Delete Team',
                          content: 'Are you sure you want to delete "${team.name}"?',
                          confirmText: 'Delete',
                          confirmColor: Colors.redAccent,
                          onConfirm: () {
                            context.read<ManageCompetitionCubit>().deleteTeam(team.id);
                          },
                        );
                      },
                      onDeleteMember: (member) {
                        onShowConfirmDialog(
                          context: context,
                          title: 'Remove Member',
                          content: 'Are you sure you want to remove "${member.name}"?',
                          confirmText: 'Remove',
                          confirmColor: Colors.redAccent,
                          onConfirm: () {
                            context.read<ManageCompetitionCubit>().removeMember(
                                  competitionId: competition.id,
                                  teamId: team.id,
                                  memberId: member.id,
                                );
                          },
                        );
                      },
                    ),
                  );
                }),

                if (rankedTeams.length > 3)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.read<ManageCompetitionCubit>().toggleShowAllTeams();
                      },
                      icon: Icon(
                        state.showAllTeams ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFFFFC107),
                      ),
                      label: Text(
                        state.showAllTeams ? 'Show Less' : 'Show All Teams (${rankedTeams.length})',
                        style: const TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 24),
              _buildDangerZone(context, state.isFinished),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardPodium(List<TeamEntity> topTeams) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium, color: Color(0xFFFFC107), size: 24),
              SizedBox(width: 8),
              Text(
                'Top Teams',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topTeams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            final rank = index + 1;

            return Padding(
              padding: EdgeInsets.only(bottom: index == topTeams.length - 1 ? 0 : 10),
              child: _buildTopTeamCard(team, rank),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopTeamCard(TeamEntity team, int rank) {
    final bool isFirst = rank == 1;

    Color badgeColor;
    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFCE195);
        break;
      case 2:
        badgeColor = const Color(0xFFD1D5DB);
        break;
      case 3:
      default:
        badgeColor = const Color(0xFFC88242);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10121D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst ? const Color(0xFFFFC107).withOpacity(0.8) : Colors.white.withOpacity(0.06),
          width: isFirst ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Team Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFirst
                    ? const Color(0xFFFFC107).withOpacity(0.5)
                    : Colors.white12,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFFFFC107),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Team Name
          Expanded(
            child: Text(
              team.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatPoints(team.totalPoints),
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'PTS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, bool isFinished) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'End Competition',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Stop allowing point modifications and lock leaderboard.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isFinished
                ? null
                : () {
                    onShowConfirmDialog(
                      context: context,
                      title: 'End Competition',
                      content:
                          'Are you sure you want to end this competition? Points will no longer be editable.',
                      confirmText: 'END COMPETITION',
                      confirmColor: Colors.orange,
                      onConfirm: () {
                        context.read<ManageCompetitionCubit>().finishCompetition();
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.withOpacity(0.2),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              isFinished ? 'COMPETITION ENDED' : 'END COMPETITION',
              style: TextStyle(
                color: isFinished ? Colors.white38 : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Delete Competition',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Permanently remove this competition and all accumulated data.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              onShowConfirmDialog(
                context: context,
                title: 'Delete Competition',
                content:
                    'This action is irreversible. Are you sure you want to delete this competition permanently?',
                confirmText: 'DELETE PERMANENTLY',
                confirmColor: Colors.redAccent,
                onConfirm: () {
                  context.read<ManageCompetitionCubit>().deleteCompetition();
                },
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: Colors.redAccent),
            ),
            child: const Text(
              'DELETE COMPETITION',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog for Creating Teams with Privacy & Join Code
class _CreateTeamDialog extends StatefulWidget {
  final List<TeamEntity> existingTeams;
  final void Function(String name, bool isPrivate, String? joinCode) onSubmit;

  const _CreateTeamDialog({
    required this.existingTeams,
    required this.onSubmit,
  });

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _joinCodeController = TextEditingController();

  bool _isPrivate = false;
  bool _obscureJoinCode = true;

  @override
  void dispose() {
    _nameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        _isPrivate,
        _isPrivate ? _joinCodeController.text.trim() : null,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161925),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create New Team', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Enter team name',
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFC107)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFC107)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a team name';
                  }
                  final trimmedName = val.trim();
                  final exists = widget.existingTeams.any(
                    (team) => team.name.trim().toLowerCase() == trimmedName.toLowerCase(),
                  );
                  if (exists) {
                    return 'this $trimmedName is used';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Private Team',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(
                    _isPrivate
                        ? 'Requires Join Code to join'
                        : 'Open for everyone',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  value: _isPrivate,
                  activeColor: const Color(0xFFFFC107),
                  onChanged: (val) {
                    setState(() {
                      _isPrivate = val;
                    });
                  },
                ),
              ),
              if (_isPrivate) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _joinCodeController,
                  obscureText: _obscureJoinCode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Join Code',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Set a Join Code',
                    hintStyle: const TextStyle(color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureJoinCode ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureJoinCode = !_obscureJoinCode;
                        });
                      },
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFC107)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFC107)),
                    ),
                  ),
                  validator: (val) {
                    if (_isPrivate && (val == null || val.trim().isEmpty)) {
                      return 'Join Code is required for private teams';
                    }
                    if (_isPrivate && val!.trim().length < 4) {
                      return 'Join Code must be at least 4 characters';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _submit,
          child: const Text(
            'Create',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamEntity team;
  final int rank;
  final bool isExpanded;
  final bool isFinished;
  final VoidCallback onToggleExpand;
  final VoidCallback onDeleteTeam;
  final Function(ParticipantEntity) onDeleteMember;

  const _TeamCard({
    required this.team,
    required this.rank,
    required this.isExpanded,
    required this.isFinished,
    required this.onToggleExpand,
    required this.onDeleteTeam,
    required this.onDeleteMember,
  });

  void _showJoinCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161925),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text('${team.name} Join Code', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this Join Code with team members:', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
              ),
              child: SelectableText(
                team.joinCode ?? 'No Join Code set',
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: team.joinCode ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join Code copied to clipboard')),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Copy Join Code', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFFFFC107) : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    color: isExpanded ? const Color(0xFFFFC107) : Colors.white54,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              team.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#$rank',
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Privacy Badge Component
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: team.isPrivate
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : Colors.greenAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: team.isPrivate ? Colors.redAccent : Colors.greenAccent,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  team.isPrivate ? Icons.lock : Icons.public,
                                  size: 10,
                                  color: team.isPrivate ? Colors.redAccent : Colors.greenAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  team.isPrivate ? 'Private' : 'Public',
                                  style: TextStyle(
                                    color: team.isPrivate ? Colors.redAccent : Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${team.members.length} Members • ${team.totalPoints} pts',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Private Join Code Inspector Action
                if (team.isPrivate)
                  IconButton(
                    icon: const Icon(Icons.key, color: Color(0xFFFFC107), size: 18),
                    tooltip: 'View join code',
                    onPressed: () => _showJoinCodeDialog(context),
                  ),

                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: onDeleteTeam,
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const Divider(color: Colors.white12, height: 20),
            if (team.members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No members in this team yet.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              )
            else
              ...team.members.asMap().entries.map((entry) {
                final idx = entry.key;
                final member = entry.value;

                return _EditableMemberRow(
                  teamId: team.id,
                  member: member,
                  rank: '#${idx + 1}',
                  isFinished: isFinished,
                  onDelete: () => onDeleteMember(member),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _EditableMemberRow extends StatelessWidget {
  final String teamId;
  final ParticipantEntity member;
  final String rank;
  final bool isFinished;
  final VoidCallback onDelete;

  const _EditableMemberRow({
    required this.teamId,
    required this.member,
    required this.rank,
    required this.isFinished,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
            onPressed: isFinished ? null : onDelete,
          ),
        ],
      ),
    );
  }
}