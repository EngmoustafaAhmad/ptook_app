import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/team_manage_tab_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/team_overview_tab_view.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

abstract class AppColors {
  static const background = Color(0xFF0D0F17);
  static const cardBackground = Color(0xFF161925);
  static const primaryGold = Color(0xFFFFC107);
  static const textSecondary = Color(0x99FFFFFF);
  static const divider = Color(0x12FFFFFF);
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF4CAF50);
}

class ManageTeamCompetitionView extends StatelessWidget {
  final CompetitionEntity competition;

  const ManageTeamCompetitionView({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ManageCompetitionCubit>(
          create: (_) => sl<ManageCompetitionCubit>()..initialize(competition),
        ),
        BlocProvider<TeamManagementCubit>(
          create: (_) => sl<TeamManagementCubit>()..listenToTeams(competition.id),
        ),
        BlocProvider<ParticipantManagementCubit>(
          create: (_) => sl<ParticipantManagementCubit>()..listenToParticipants(competition.id),
        ),
      ],
      child: _ManageTeamCompetitionContent(initialCompetition: competition),
    );
  }
}

class _ManageTeamCompetitionContent extends StatefulWidget {
  final CompetitionEntity initialCompetition;

  const _ManageTeamCompetitionContent({required this.initialCompetition});

  @override
  State<_ManageTeamCompetitionContent> createState() => _ManageTeamCompetitionContentState();
}

class _ManageTeamCompetitionContentState extends State<_ManageTeamCompetitionContent> {
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ===========================================================================
  // DIALOG FLOWS FOR MANAGEMENT ACTIONS
  // ===========================================================================

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Private Team', style: TextStyle(color: Colors.white, fontSize: 14)),
                value: isPrivate,
                activeColor: AppColors.primaryGold,
                onChanged: (val) => setDialogState(() => isPrivate = val),
              ),
              if (isPrivate)
                TextField(
                  controller: codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Join Code',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              onPressed: () {
                final teamName = nameController.text.trim();
                if (teamName.isNotEmpty) {
                  context.read<TeamManagementCubit>().createTeam(
                        competitionId: widget.initialCompetition.id,
                        teamName: teamName,
                        isPrivate: isPrivate,
                        ownerId: _currentUserId,
                        joinCode: isPrivate ? codeController.text.trim() : null,
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePointsDialog({
    required BuildContext context,
    required String targetName,
    required Function(int points) onUpdate,
  }) {
    final pointsController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Adjust Points: $targetName', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: pointsController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Points Delta (e.g., 10 or -5)',
            labelStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () {
              final pts = int.tryParse(pointsController.text.trim()) ?? 0;
              if (pts != 0) {
                onUpdate(pts);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Update', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.group_add_rounded, color: AppColors.primaryGold),
              title: const Text('Create Team', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showCreateTeamDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.amber),
              title: const Text('Finish Competition', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showConfirmationDialog(
                  context: context,
                  title: 'Finish Competition',
                  content: 'Are you sure you want to finish this competition? This action cannot be undone.',
                  confirmText: 'Finish',
                  confirmColor: Colors.amber.shade800,
                  onConfirm: () => context.read<ManageCompetitionCubit>().finishCompetition(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
              title: const Text('Delete Competition', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showConfirmationDialog(
                  context: context,
                  title: 'Delete Competition',
                  content: 'This will permanently delete the competition and all associated teams/points.',
                  confirmText: 'Delete',
                  confirmColor: AppColors.error,
                  onConfirm: () => context.read<ManageCompetitionCubit>().deleteCompetition(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MAIN BUILD & LISTENERS
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
          listener: (context, state) {
            if (state.status == ManageCompetitionStatus.failure && state.errorMessage != null) {
              _showSnackBar(context, state.errorMessage!, AppColors.error);
            } else if (state.status == ManageCompetitionStatus.actionSuccess && state.successMessage != null) {
              _showSnackBar(context, state.successMessage!, AppColors.success);
            } else if (state.status == ManageCompetitionStatus.finished) {
              _showSnackBar(context, state.successMessage ?? 'Competition finished!', Colors.amber.shade800);
            } else if (state.status == ManageCompetitionStatus.deleted) {
              _showSnackBar(context, state.successMessage ?? 'Competition deleted', AppColors.error);
              Navigator.of(context).pop();
            }
          },
        ),
        BlocListener<TeamManagementCubit, TeamManagementState>(
          listener: (context, state) {
            if (state is TeamManagementFailure) {
              _showSnackBar(context, state.error, AppColors.error);
            } else if (state is TeamActionSuccess) {
              _showSnackBar(context, state.message, AppColors.success);
            }
          },
        ),
        BlocListener<ParticipantManagementCubit, ParticipantManagementState>(
          listener: (context, state) {
            if (state is ParticipantManagementFailure) {
              _showSnackBar(context, state.error, AppColors.error);
            } else if (state is ParticipantActionSuccess) {
              _showSnackBar(context, state.message, AppColors.success);
            }
          },
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
              builder: (context, state) {
                final title = state.competition?.name ?? widget.initialCompetition.name;
                final status = state.competition?.status ?? widget.initialCompetition.status;
                final isFinished = status.toLowerCase() == 'finished' ||
                    state.status == ManageCompetitionStatus.finished;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: isFinished ? Colors.amber : AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isFinished ? 'FINISHED' : status.toUpperCase(),
                          style: TextStyle(
                            color: isFinished ? Colors.amber : AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => _showSettingsMenu(context),
              ),
            ],
            bottom: const TabBar(
              indicatorColor: AppColors.primaryGold,
              indicatorWeight: 3,
              labelColor: AppColors.primaryGold,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Manage'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const TeamOverviewTabView(),
              TeamManageTabView(
                onShowConfirmDialog: _showConfirmationDialog,
                competition: widget.initialCompetition,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}