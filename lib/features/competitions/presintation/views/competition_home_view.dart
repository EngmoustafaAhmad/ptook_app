  import 'package:flutter/material.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/views/competition_individual_home_view.dart';
import 'package:ptook/features/competitions/presintation/views/competition_team_home_view.dart';

// Key Theme Colors
abstract class _AppColors {
  static const background = Color(0xFF0F111A);
  static const cardBackground = Color(0xFF1B1E2B);
  static const primaryAccent = Color(0xFF9D61FF);
  static const secondaryGradient = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
}

class CompetitionHomeView extends StatefulWidget {
  final CompetitionEntity competition;
  final String currentUserId;

  const CompetitionHomeView({
    super.key,
    required this.competition,
    required this.currentUserId, required String competitionId,
  });

  @override
  State<CompetitionHomeView> createState() => _CompetitionHomeViewState();
}

class _CompetitionHomeViewState extends State<CompetitionHomeView> {
  @override
  Widget build(BuildContext context) {
    final isTeam = widget.competition.type.toString().toLowerCase().contains('team');

    if (isTeam) {
      return CompetitionTeamHomeView(
        competition: widget.competition,
        currentUserId: widget.currentUserId,
      );
    }

    return CompetitionIndividualHomeView(
      competition: widget.competition,
      currentUserId: widget.currentUserId, 
      competitionId: widget.competition.id,
    );
  }
}





