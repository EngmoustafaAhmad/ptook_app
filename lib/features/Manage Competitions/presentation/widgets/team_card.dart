import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/editable_member_row.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class TeamCard extends StatelessWidget {
  final String competitionId;
  final TeamEntity team;
  final int rank;
  final bool isExpanded;
  final bool isFinished;
  final VoidCallback onToggleExpand;
  final VoidCallback onDeleteTeam;
  final Function(ParticipantEntity) onDeleteMember;

  const TeamCard({
    super.key,
    required this.team,
    required this.rank,
    required this.isExpanded,
    required this.isFinished,
    required this.onToggleExpand,
    required this.onDeleteTeam,
    required this.onDeleteMember,
     required this.competitionId,
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
            Expanded(
              child: Text(
                '${team.name} Join Code',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this Join Code with team members:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
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
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join Code copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Copy Join Code',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
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
            borderRadius: BorderRadius.circular(8),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: team.isPrivate
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : Colors.greenAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: team.isPrivate
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  team.isPrivate ? Icons.lock : Icons.public,
                                  size: 10,
                                  color: team.isPrivate
                                      ? Colors.redAccent
                                      : Colors.greenAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  team.isPrivate ? 'Private' : 'Public',
                                  style: TextStyle(
                                    color: team.isPrivate
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${team.members.length} Members • ${team.totalPoints} pts',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon buttons wrapped in Material to prevent gesture interference
                if (team.isPrivate)
                  IconButton(
                    icon: const Icon(
                      Icons.key,
                      color: Color(0xFFFFC107),
                      size: 18,
                    ),
                    tooltip: 'View join code',
                    onPressed: () => _showJoinCodeDialog(context),
                  ),

                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: onDeleteTeam,
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
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

                return EditableMemberRow(
                  competitionId: competitionId, // Pass from TeamCard
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