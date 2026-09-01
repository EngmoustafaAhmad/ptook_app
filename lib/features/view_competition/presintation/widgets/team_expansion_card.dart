
import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class TeamExpansionCard extends StatefulWidget {
  final TeamEntity team;
  final int rank;
  final bool isJoined;
  final bool hasJoinedOtherTeam;
  final String currentUserId;
  final bool isCompetitionEnded;
  final int? maxMembersLimit;
  final bool isActionPending;
  final VoidCallback onToggleJoin;

  const TeamExpansionCard({
    super.key, 
    required this.team,
    required this.rank,
    required this.isJoined,
    required this.hasJoinedOtherTeam,
    required this.currentUserId,
    required this.isCompetitionEnded,
    required this.maxMembersLimit,
    required this.isActionPending,
    required this.onToggleJoin,
  });

  @override
  State<TeamExpansionCard> createState() => TeamExpansionCardState();
}

class TeamExpansionCardState extends State<TeamExpansionCard> {
  bool _isExpanded = false;

  String _getButtonText({required bool isPrivate, required bool isFull}) {
    if (widget.isJoined) return 'Leave';
    if (isFull) return 'Full';
    if (widget.hasJoinedOtherTeam) return 'Switch';
    return isPrivate ? 'Join (Code)' : 'Join';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.goldAccent;
      case 2:
        return AppColors.silverAccent;
      case 3:
        return AppColors.bronzeAccent;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrivate = widget.team.isPrivate;
    final bool isFull = widget.maxMembersLimit != null &&
        widget.team.members.length >= widget.maxMembersLimit! &&
        !widget.isJoined;

    final members = List.from(widget.team.members)
      ..sort((a, b) => (b.points ?? 0).compareTo(a.points ?? 0));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isJoined
              ? AppColors.primaryPurple
              : AppColors.borderOutline,
          width: widget.isJoined ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getRankColor(widget.rank).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${widget.rank}',
                    style: TextStyle(
                      color: _getRankColor(widget.rank),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
                              widget.team.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isPrivate ? Icons.lock_outline : Icons.public,
                            size: 14,
                            color: isPrivate
                                ? AppColors.privateRed
                                : AppColors.publicGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.team.totalPoints} pts • ${widget.team.members.length}'
                        '${widget.maxMembersLimit != null ? '/${widget.maxMembersLimit}' : ''} members',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isCompetitionEnded) ...[
                  ElevatedButton(
                    onPressed: (isFull || widget.isActionPending)
                        ? null
                        : widget.onToggleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isJoined
                          ? Colors.redAccent.withOpacity(0.15)
                          : (isFull ? Colors.white10 : AppColors.primaryPurple),
                      foregroundColor: widget.isJoined
                          ? Colors.redAccent
                          : (isFull ? Colors.white38 : Colors.white),
                      elevation: 0,
                      side: widget.isJoined
                          ? const BorderSide(color: Colors.redAccent, width: 1)
                          : BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      _getButtonText(isPrivate: isPrivate, isFull: isFull),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(color: AppColors.borderOutline, height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'Participant Rankings',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No participants in this team yet.',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, idx) {
                        final member = members[idx];
                        final isMe = member.id == widget.currentUserId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColors.primaryPurple.withOpacity(0.2)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '#${idx + 1}',
                                style: TextStyle(
                                  color: isMe
                                      ? AppColors.primaryPurple
                                      : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  member.name + (isMe ? ' (You)' : ''),
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.white70,
                                    fontWeight: isMe
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${member.points ?? 0} pts',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}