import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/domain/entities/team_entity.dart';
import 'package:ptook/features/competitions/domain/repositories/i_competition_repository.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';

abstract class _AppTheme {
  static const background = Color(0xFF0D0F17);
  static const cardBackground = Color(0xFF161926);
  static const borderOutline = Color(0xFF262B3E);
  static const goldAccent = Color(0xFFFFD700);
  static const silverAccent = Color(0xFFC0C0C0);
  static const bronzeAccent = Color(0xFFCD7F32);
  static const primaryPurple = Color(0xFF9D61FF);
  static const publicGreen = Color(0xFF2ECC71);
  static const privateRed = Color(0xFFE74C3C);
}

class CompetitionTeamHomeView extends StatelessWidget {
  final CompetitionEntity competition;
  final String currentUserId;
  final String currentUserName;

  const CompetitionTeamHomeView({
    super.key,
    required this.competition,
    required this.currentUserId,
    this.currentUserName = 'Current User',
  });

  int? _getCapacityLimit(TeamEntity team) {
    try {
      final dynamic t = team;
      if (t.maxMembers != null && (t.maxMembers as num) > 0) {
        return (t.maxMembers as num).toInt();
      }
      final dynamic comp = competition;
      if (comp.maxTeamMembers != null && (comp.maxTeamMembers as num) > 0) {
        return (comp.maxTeamMembers as num).toInt();
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ManageCompetitionCubit>(),
      child: BlocConsumer<ManageCompetitionCubit, ManageCompetitionState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null || current.successMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: _AppTheme.privateRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: _AppTheme.publicGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, cubitState) {
          final isLoading =
              cubitState.status == ManageCompetitionStatus.loading ||
                  cubitState.status == ManageCompetitionStatus.actionInProgress;

          final isCompetitionEnded =
              cubitState.isFinished || (competition.isFinished);

          return Scaffold(
            backgroundColor: _AppTheme.background,
            appBar: AppBar(
              backgroundColor: _AppTheme.background,
              elevation: 0,
              centerTitle: false,
              title: Text(
                competition.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              bottom: isLoading
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(2),
                      child: LinearProgressIndicator(
                        color: _AppTheme.primaryPurple,
                        backgroundColor: Colors.transparent,
                      ),
                    )
                  : null,
            ),
            body: StreamBuilder<List<TeamEntity>>(
              stream: sl<ICompetitionRepository>().streamTeams(competition.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _AppTheme.primaryPurple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final teams = snapshot.data ?? [];
                if (teams.isEmpty) {
                  return _buildEmptyState();
                }

                final sortedTeams = List<TeamEntity>.from(teams)
                  ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

                final topThree = sortedTeams.take(3).toList();

                final userCurrentTeam = sortedTeams.cast<TeamEntity?>().firstWhere(
                      (t) => t?.members.any((m) => m.id == currentUserId) ?? false,
                      orElse: () => null,
                    );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCompetitionEnded && topThree.isNotEmpty) ...[
                        _buildPodiumContainer(topThree),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCompetitionEnded
                                ? 'Final Standings'
                                : 'Team Leaderboard',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${sortedTeams.length} Teams',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedTeams.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final team = sortedTeams[index];
                          final isUserInThisTeam = userCurrentTeam?.id == team.id;

                          return _TeamExpansionCard(
                            team: team,
                            rank: index + 1,
                            isJoined: isUserInThisTeam,
                            hasJoinedOtherTeam:
                                userCurrentTeam != null && !isUserInThisTeam,
                            currentUserId: currentUserId,
                            isCompetitionEnded: isCompetitionEnded,
                            maxMembersLimit: _getCapacityLimit(team),
                            isActionPending: isLoading,
                            onToggleJoin: () => _handleJoinLeave(
                              context: context,
                              targetTeam: team,
                              userCurrentTeam: userCurrentTeam,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleJoinLeave({
    required BuildContext context,
    required TeamEntity targetTeam,
    required TeamEntity? userCurrentTeam,
  }) async {
    final cubit = context.read<ManageCompetitionCubit>();

    // 1. LEAVE CURRENT TEAM
    if (userCurrentTeam?.id == targetTeam.id) {
      final bool? confirmLeave = await _showConfirmationDialog(
        context,
        title: 'Leave Team?',
        message: 'Are you sure you want to leave "${targetTeam.name}"?',
        confirmText: 'Leave',
        confirmColor: Colors.redAccent,
      );

      if (confirmLeave == true && context.mounted) {
        cubit.leaveTeam(teamId: targetTeam.id);
      }
      return;
    }

    // 2. CAPACITY GUARD
    final capacityLimit = _getCapacityLimit(targetTeam);
    final isFull =
        capacityLimit != null && targetTeam.members.length >= capacityLimit;

    if (isFull) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This team has reached its maximum member limit.'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 3. SWITCH TEAM FLOW
    if (userCurrentTeam != null) {
      final bool? confirmSwitch = await _showConfirmationDialog(
        context,
        title: 'Switch Team?',
        message:
            'You are currently a member of "${userCurrentTeam.name}". You can only participate in one team at a time.\n\nDo you want to leave "${userCurrentTeam.name}" and join "${targetTeam.name}"?',
        confirmText: 'Switch Team',
        confirmColor: _AppTheme.primaryPurple,
      );

      if (confirmSwitch != true) return;
    }

    // 4. PRIVATE TEAM JOIN CODE GUARD
    dynamic dynamicTeam = targetTeam;
    final bool isPrivate = dynamicTeam.isPrivate == true;
    String? joinCode;

    if (isPrivate) {
      joinCode = await _showJoinCodeDialog(context, targetTeam.name);
      if (joinCode == null || joinCode.trim().isEmpty) return;

      final String expectedCode = dynamicTeam.joinCode?.toString() ?? '';
      if (expectedCode.isNotEmpty && joinCode.trim() != expectedCode.trim()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid team join code. Access denied.'),
              backgroundColor: _AppTheme.privateRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // 5. EXECUTE JOIN / SWITCH ACTION
    if (userCurrentTeam != null) {
      await cubit.leaveTeam(teamId: userCurrentTeam.id);
    }

    if (context.mounted) {
      cubit.joinTeam(
        competitionId: competition.id,
        teamId: targetTeam.id,
        joinCode: joinCode,
      );
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _AppTheme.borderOutline),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _showJoinCodeDialog(BuildContext context, String teamName) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _AppTheme.borderOutline),
        ),
        title: Text(
          'Join $teamName',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is a private team. Enter the team join code to gain access:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Code',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _AppTheme.borderOutline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _AppTheme.primaryPurple),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppTheme.primaryPurple,
            ),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumContainer(List<TeamEntity> topThree) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: _AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppTheme.borderOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🏆 Final Podium Winners',
                style: TextStyle(
                  color: _AppTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: second != null
                    ? _buildPodiumAvatar(
                        team: second,
                        rank: 2,
                        accentColor: _AppTheme.silverAccent,
                        avatarSize: 60,
                        isCenter: false,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: first != null
                    ? _buildPodiumAvatar(
                        team: first,
                        rank: 1,
                        accentColor: _AppTheme.goldAccent,
                        avatarSize: 80,
                        isCenter: true,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: third != null
                    ? _buildPodiumAvatar(
                        team: third,
                        rank: 3,
                        accentColor: _AppTheme.bronzeAccent,
                        avatarSize: 55,
                        isCenter: false,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar({
    required TeamEntity team,
    required int rank,
    required Color accentColor,
    required double avatarSize,
    required bool isCenter,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: isCenter ? 3 : 2,
                ),
                boxShadow: isCenter
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: _AppTheme.borderOutline,
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCenter ? 24 : 18,
                  ),
                ),
              ),
            ),
            Positioned(
              top: isCenter ? -4 : 4,
              child: isCenter
                  ? const Icon(
                      Icons.workspace_premium,
                      color: _AppTheme.goldAccent,
                      size: 28,
                    )
                  : Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _AppTheme.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 1.5),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isCenter ? FontWeight.bold : FontWeight.w600,
            fontSize: isCenter ? 15 : 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${team.totalPoints} pts',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: isCenter ? 14 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 64, color: Colors.white38),
          SizedBox(height: 12),
          Text(
            'No teams available in this competition yet.',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Error loading team data:\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _TeamExpansionCard extends StatefulWidget {
  final TeamEntity team;
  final int rank;
  final bool isJoined;
  final bool hasJoinedOtherTeam;
  final String currentUserId;
  final bool isCompetitionEnded;
  final int? maxMembersLimit;
  final bool isActionPending;
  final VoidCallback onToggleJoin;

  const _TeamExpansionCard({
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
  State<_TeamExpansionCard> createState() => _TeamExpansionCardState();
}

class _TeamExpansionCardState extends State<_TeamExpansionCard> {
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
        return _AppTheme.goldAccent;
      case 2:
        return _AppTheme.silverAccent;
      case 3:
        return _AppTheme.bronzeAccent;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic dynamicTeam = widget.team;
    final bool isPrivate = dynamicTeam.isPrivate == true;
    final bool isFull = widget.maxMembersLimit != null &&
        widget.team.members.length >= widget.maxMembersLimit! &&
        !widget.isJoined;

    final members = List.from(widget.team.members)
      ..sort((a, b) => ((b.points ?? 0) as num).compareTo((a.points ?? 0) as num));

    return Container(
      decoration: BoxDecoration(
        color: _AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isJoined
              ? _AppTheme.primaryPurple
              : _AppTheme.borderOutline,
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
                                ? _AppTheme.privateRed
                                : _AppTheme.publicGreen,
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
                          : (isFull ? Colors.white10 : _AppTheme.primaryPurple),
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
            const Divider(color: _AppTheme.borderOutline, height: 1),
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
                                ? _AppTheme.primaryPurple.withOpacity(0.2)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '#${idx + 1}',
                                style: TextStyle(
                                  color: isMe
                                      ? _AppTheme.primaryPurple
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