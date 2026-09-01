import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_participants/view_participants_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/view_teams/view_teams_cubit.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_individual_home_view.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_team_home_view.dart';

class CompetitionHomeView extends StatelessWidget {
  final CompetitionEntity competition;
  final String currentUserId;
  final String competitionId;

  const CompetitionHomeView({
    super.key,
    required this.competition,
    required this.currentUserId,
    required this.competitionId,
  });

  @override
  Widget build(BuildContext context) {
    final isTeam = widgetOrThisCompetitionIsTeam(competition);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CompetitionHomeCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<ViewParticipantsCubit>()
            ..listenToParticipants(competitionId),
        ),
        BlocProvider(
          create: (_) => sl<ViewTeamsCubit>(),
        ),
      ],
      child: isTeam
          ? CompetitionTeamHomeView(
              competition: competition, 
              currentUserId: currentUserId,
          )
          : CompetitionIndividualHomeView(
              competition: competition,
              currentUserId: currentUserId,
            ),
    );
  }

  bool widgetOrThisCompetitionIsTeam(CompetitionEntity comp) {
    return comp.type.toString().toLowerCase().contains('team');
  }
}