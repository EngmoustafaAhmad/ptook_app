import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/manage_competition/manage_competition_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/team_management/team_management_state.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_individual_competition_view.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/pages/manage_team_competition_view.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import '../../../../core/di/injection_container.dart';


/// Entry point view for managing a competition.
///
/// Wraps child views with feature-specific Cubits and routes dynamically
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ManageCompetitionCubit>()
            ..streamCompetition(competition.id),
        ),
        BlocProvider(
          create: (context) {
            final cubit = sl<ParticipantManagementCubit>();
            if (!_isTeamCompetition) {
              cubit.listenToParticipants(competition.id);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = sl<TeamManagementCubit>();
            if (_isTeamCompetition) {
              cubit.listenToTeams(competition.id);
            }
            return cubit;
          },
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Manage Competition Listener
          BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
            listener: (context, state) {
              if (state is ManageCompetitionFailure) {
                _showSnackBar(context, state.error, isError: true);
              } else if (state is ManageCompetitionActionSuccess) {
                _showSnackBar(context, state.message);
              }
            },
          ),
          // Participant Management Listener
          BlocListener<ParticipantManagementCubit, ParticipantManagementState>(
            listener: (context, state) {
              if (state is ParticipantManagementFailure) {
                _showSnackBar(context, state.error, isError: true);
              } else if (state is ParticipantActionSuccess) {
                _showSnackBar(context, state.message);
              }
            },
          ),
          // Team Management Listener
          BlocListener<TeamManagementCubit, TeamManagementState>(
            listener: (context, state) {
              if (state is TeamManagementFailure) {
                _showSnackBar(context, state.error, isError: true);
              } else if (state is TeamActionSuccess) {
                _showSnackBar(context, state.message);
              }
            },
          ),
        ],
        child: _isTeamCompetition
            ? ManageTeamCompetitionView(competition: competition)
            : ManageIndividualCompetitionView(
                competition: competition,
                competitionId: competition.id,
              ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}