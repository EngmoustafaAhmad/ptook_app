import 'package:flutter/material.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';

class CompetitionDetailsView extends StatefulWidget {
  const CompetitionDetailsView({super.key, required CompetitionEntity competition, required bool isOwner});

  @override
  State<CompetitionDetailsView> createState() => _CompetitionDetailsViewState();
}

class _CompetitionDetailsViewState extends State<CompetitionDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}