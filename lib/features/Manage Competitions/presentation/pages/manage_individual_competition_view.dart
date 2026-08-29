import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/individual_manage_tab_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/widgets/individual_overview_tab_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
      listener: (context, state) {
        if (state.status == ManageCompetitionStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competition deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }

        if (state.status == ManageCompetitionStatus.finished) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competition finished successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state.status == ManageCompetitionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0F17),
          appBar: AppBar(
            backgroundColor: const Color(0xFF161925),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
              builder: (context, state) {
                final compName =
                    state.competition?.name ?? widget.competition.name;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compName,
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Individual Management',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
            bottom: const TabBar(
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
        ),
      ),
    );
  }
}