import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart'; // Adjust based on your DI setup
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';
import 'manage_individual_competition_view.dart';
import 'manage_team_competition_view.dart';

/// Entry point view for managing a competition.
///
/// Wraps child views with [ManageCompetitionCubit] and routes dynamically
/// based on [CompetitionType].
class ManageCompetitionView extends StatelessWidget {
  final CompetitionEntity competition;

  const ManageCompetitionView({
    super.key,
    required this.competition,
  });

  bool get _isTeamCompetition =>
      competition.type.trim().toLowerCase() == 'team';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ManageCompetitionCubit>()..initialize(competition),
      child: BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: _isTeamCompetition
            ? ManageTeamCompetitionView(competition: competition)
            : ManageIndividualCompetitionView(
                competition: competition,
                competitionId: competition.id,
              ),
      ),
    );
  }
}