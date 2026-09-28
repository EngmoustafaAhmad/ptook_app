import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class ManageTeamMembersScreen extends StatefulWidget {
  final TeamEntity team;
  final String competitionId;
  final String ownerId; // 👑 ID of competition creator/owner

  const ManageTeamMembersScreen({
    super.key,
    required this.team,
    required this.competitionId,
    required this.ownerId,
  });

  @override
  State<ManageTeamMembersScreen> createState() => _ManageTeamMembersScreenState();
}

class _ManageTeamMembersScreenState extends State<ManageTeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    // 📡 Stream active participants for this competition
    context
        .read<ParticipantManagementCubit>()
        .listenToParticipants(widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwner = currentUserId == widget.ownerId;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: Text('${widget.team.name} Members'),
        backgroundColor: const Color(0xFF161925),
        elevation: 0,
      ),
      body: BlocBuilder<ParticipantManagementCubit, ParticipantManagementState>(
        builder: (context, state) {
          if (state is ParticipantManagementLoading && state.participants.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }

          if (state is ParticipantManagementFailure && state.participants.isEmpty) {
            return Center(
              child: Text(
                state.error,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            );
          }

          // 🔄 Reconcile stream data with active team member IDs
          final teamMemberIds = widget.team.members.map((m) => m.id).toSet();

          final teamMembers = state.participants
              .where((p) => teamMemberIds.contains(p.id) || p.teamId == widget.team.id)
              .toList()
            ..sort((a, b) => b.points.compareTo(a.points));

          if (teamMembers.isEmpty) {
            return const Center(
              child: Text(
                'No members in this team yet.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: teamMembers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              final isMe = member.id == currentUserId;

              return _MemberTile(
                key: ValueKey(member.id),
                member: member,
                rank: index + 1,
                isMe: isMe,
                isOwner: isOwner,
              );
            },
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final ParticipantEntity member;
  final int rank;
  final bool isMe;
  final bool isOwner;

  const _MemberTile({
    super.key,
    required this.member,
    required this.rank,
    required this.isMe,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final String name = member.name;
    final int points = member.points;
    final hasAvatar = member.avatarUrl != null && member.avatarUrl!.trim().isNotEmpty;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFFFFC107).withValues(alpha: 0.5) : Colors.white10,
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // 🥇 Rank Indicator
          Text(
            '#$rank',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),

          // 🖼️ Avatar Image with Fallback Initial
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.2),
            backgroundImage: hasAvatar
                ? CachedNetworkImageProvider(member.avatarUrl!)
                : null,
            child: !hasAvatar
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // 👤 Member Info & Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}