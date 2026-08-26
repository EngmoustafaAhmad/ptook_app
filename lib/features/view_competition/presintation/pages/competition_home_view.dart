import 'package:flutter/material.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_individual_home_view.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_team_home_view.dart';

class CompetitionHomeView extends StatelessWidget {
  final CompetitionEntity competition;
  final String currentUserId;

  const CompetitionHomeView({
    super.key,
    required this.competition,
    required this.currentUserId, required String competitionId,
  });

  @override
  Widget build(BuildContext context) {
    final isTeam = widgetOrThisCompetitionIsTeam(competition);

    if (isTeam) {
      return CompetitionTeamHomeView(
        competition: competition,
        currentUserId: currentUserId,
      );
    }

    return CompetitionIndividualHomeView(
      competition: competition,
      currentUserId: currentUserId,
      competitionId: competition.id,
    );
  }

  bool widgetOrThisCompetitionIsTeam(CompetitionEntity comp) {
    return comp.type.toString().toLowerCase().contains('team');
  }
}