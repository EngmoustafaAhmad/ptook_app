import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_team_members_screen.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/team_card.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/team_entity.dart';

class ManageAllTeamsScreen extends StatelessWidget {
  final CompetitionEntity competition;
  final void Function({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) onShowConfirmDialog;

  const ManageAllTeamsScreen({
    super.key,
    required this.competition,
    required this.onShowConfirmDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('Manage Teams'),
        backgroundColor: const Color(0xFF161925),
        elevation: 0,
      ),
      body: BlocBuilder<TeamManagementCubit, TeamManagementState>(
        builder: (context, state) {
          final teams = state.rankedTeams;

          if (teams.isEmpty) {
            return const Center(
              child: Text(
                'No teams found.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final team = teams[index];

              return TeamCard(
                team: team,
                rank: index + 1,
                isFinished: competition.isFinished,
                competitionId: competition.id,
                onTap: () => _navigateToTeamMembers(context, team),
                onDeleteTeam: () {
                  onShowConfirmDialog(
                    context: context,
                    title: 'Delete Team',
                    content: 'Are you sure you want to delete "${team.name}"?',
                    confirmText: 'Delete',
                    confirmColor: Colors.redAccent,
                    onConfirm: () {
                      context.read<TeamManagementCubit>().deleteTeam(
                            competitionId: competition.id,
                            teamId: team.id,
                          );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToTeamMembers(BuildContext context, TeamEntity team) {
    final participantCubit = context.read<ParticipantManagementCubit>();
    participantCubit.listenToParticipants(competition.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: participantCubit,
          child: ManageTeamMembersScreen(
            team: team,
            competitionId: competition.id,
            ownerId: competition.ownerId,
          ),
        ),
      ),
    );
  }
}