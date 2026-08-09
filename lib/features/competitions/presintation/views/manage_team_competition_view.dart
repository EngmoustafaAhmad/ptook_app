import 'package:flutter/material.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/presintation/widgets/info_card.dart';
import 'package:ptook/features/competitions/presintation/widgets/info_row.dart';
import 'package:ptook/features/competitions/presintation/widgets/invite_code_card.dart';
import '../../domain/entities/competition_entity.dart';

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

class _ManageTeamCompetitionViewState extends State<ManageTeamCompetitionView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          children: [
            Text(
              widget.competition.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Team Management',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "Overview", icon: Icon(Icons.dashboard_outlined, size: 20)),
            Tab(text: "Teams", icon: Icon(Icons.groups_outlined, size: 20)),
            Tab(text: "Settings", icon: Icon(Icons.tune_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TeamOverviewTab(competition: widget.competition),
          _TeamsListTab(competition: widget.competition),
          _TeamSettingsTab(competition: widget.competition),
        ],
      ),
    );
  }
}

class _TeamOverviewTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _TeamOverviewTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          InfoCard(
            title: "Team Structure",
            items: [
              InfoRow(label: "Max Teams", value: "${competition.maxTeams ?? 'Unlimited'}"),
              InfoRow(
                label: "Members / Team",
                value: "${competition.membersPerTeam ?? 'Flexible'}",
              ),
            ],
          ),
          20.vs,
          InviteCodeCard(inviteCode: competition.inviteCode),
        ],
      ),
    );
  }
}

class _TeamsListTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _TeamsListTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    final teams = competition.teams ?? [];

    if (teams.isEmpty) {
      return Center(
        child: Text(
          "No teams joined yet.",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: teams.length,
      separatorBuilder: (_, __) => 12.vs,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.groups, color: AppColors.primary),
              12.hs,
              Expanded(
                child: Text(
                  team.name ?? 'Team ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${team.points ?? 0} pts",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamSettingsTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _TeamSettingsTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Team Competition Settings",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}