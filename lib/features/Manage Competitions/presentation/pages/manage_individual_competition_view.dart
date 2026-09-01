import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_team_competition_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/individual_manage_tab_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/individual_overview_tab_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/management_appbar.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';

class ManageIndividualCompetitionView extends StatefulWidget {
  final String competitionId;
  final CompetitionEntity competition;

  const ManageIndividualCompetitionView({
    super.key,
    required this.competitionId,
    required this.competition,
  });

  @override
  State<ManageIndividualCompetitionView> createState() =>
      _ManageIndividualCompetitionViewState();
}

class _ManageIndividualCompetitionViewState
    extends State<ManageIndividualCompetitionView> {
  @override
  void initState() {
    super.initState();
    context.read<ManageCompetitionCubit>().resetState();
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
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? const Color(0xFFFF5252),
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

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161925),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Wrap(
            children: [
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
                leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF5252)),
                title: const Text('Delete Competition', style: TextStyle(color: Color(0xFFFF5252))),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showConfirmationDialog(
                    context: context,
                    title: 'Delete Competition',
                    content: 'This will permanently delete the competition and all associated data.',
                    confirmText: 'Delete',
                    confirmColor: const Color(0xFFFF5252),
                    onConfirm: () => context.read<ManageCompetitionCubit>().deleteCompetition(),
                  );
                },
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
      listener: (context, state) {
        if (state.status == ManageCompetitionStatus.deleted) {
          _showSnackBar(
            context,
            'Competition deleted successfully',
            Colors.green,
          );
          Navigator.of(context).pop(true);
        }

        if (state.status == ManageCompetitionStatus.finished) {
          _showSnackBar(
            context,
            'Competition finished successfully',
            Colors.green,
          );
        }

        if (state.status == ManageCompetitionStatus.failure &&
            state.errorMessage != null) {
          _showSnackBar(context, state.errorMessage!, Colors.redAccent);
        }
      },
      child: DefaultTabController(
        length: 2,
        child: BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
          builder: (context, state) {
            final title = state.competition?.name ?? widget.competition.name;
            final rawStatus = state.competition?.status ?? widget.competition.status;
            final isFinished = rawStatus.toLowerCase() == 'finished' ||
                state.status == ManageCompetitionStatus.finished;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: ManagementAppBar(
                title: title,
                status: rawStatus,
                isFinished: isFinished,
                onSettingsTap: () => _showSettingsMenu(context),
                bottomTabBar: const TabBar(
                  indicatorColor: Color(0xFFFFC107),
                  indicatorWeight: 3,
                  labelColor: Color(0xFFFFC107),
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(text: 'Preview'),
                    Tab(text: 'Edit'),
                  ],
                ), 
              ),
              body: const TabBarView(
                children: [
                  IndividualOverviewTabView(),
                  IndividualManageTabView(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}