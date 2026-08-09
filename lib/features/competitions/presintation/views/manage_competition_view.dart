import 'package:flutter/material.dart';
import '../../domain/entities/competition_entity.dart';
import 'manage_individual_competition_view.dart';
import 'manage_team_competition_view.dart';

/// Entry point view for managing a competition.
///
/// Routes dynamically based on [CompetitionType] to prevent bloated single-file views.
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
    if (_isTeamCompetition) {
      return ManageTeamCompetitionView(competition: competition);
    }

    return ManageIndividualCompetitionView(competition: competition);
  }
}