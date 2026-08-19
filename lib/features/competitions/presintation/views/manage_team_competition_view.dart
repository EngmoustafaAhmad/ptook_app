import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';
import 'package:ptook/features/competitions/presintation/widgets/team_manage_tab_view.dart';
import 'package:ptook/features/competitions/presintation/widgets/team_overriew_tab_view.dart';

class ManageTeamCompetitionView extends StatefulWidget {
  final CompetitionEntity competition;

  const ManageTeamCompetitionView({
    super.key,
    required this.competition,
  });

  @override
  State<ManageTeamCompetitionView> createState() =>
      _ManageTeamCompetitionViewState();
}

class _ManageTeamCompetitionViewState extends State<ManageTeamCompetitionView> {
  @override
  void initState() {
    super.initState();
    context.read<ManageCompetitionCubit>().initialize(widget.competition);
  }

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
        backgroundColor: const Color(0xFF161925),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.redAccent,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
      listener: (context, state) {
        if (state.status == ManageCompetitionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state.status == ManageCompetitionStatus.actionSuccess &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == ManageCompetitionStatus.finished) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Competition finished!'),
              backgroundColor: Colors.amber.shade800,
            ),
          );
        } else if (state.status == ManageCompetitionStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Competition deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0F17),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D0F17),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
              builder: (context, state) {
                final title = state.competition?.name ?? widget.competition.name;
                final status = state.competition?.status ?? widget.competition.status;
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
                          backgroundColor: isFinished ? Colors.amber : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isFinished ? 'FINISHED' : status.toUpperCase(),
                          style: TextStyle(
                            color: isFinished ? Colors.amber : Colors.green,
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
                onPressed: () {
                  // Navigate to Competition Settings
                },
              ),
            ],
            bottom: const TabBar(
              indicatorColor: Color(0xFFFFC107),
              indicatorWeight: 3,
              labelColor: Color(0xFFFFC107),
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
                competition: widget.competition,
              ),
            ],
          ),
        ),
      ),
    );
  }
}