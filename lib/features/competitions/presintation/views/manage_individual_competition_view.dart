import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/presintation/widgets/info_card.dart';
import 'package:ptook/features/competitions/presintation/widgets/info_row.dart';
import 'package:ptook/features/competitions/presintation/widgets/invite_code_card.dart';
import '../../domain/entities/competition_entity.dart';

class ManageIndividualCompetitionView extends StatefulWidget {
  final CompetitionEntity competition;

  const ManageIndividualCompetitionView({
    super.key,
    required this.competition,
  });

  @override
  State<ManageIndividualCompetitionView> createState() =>
      _ManageIndividualCompetitionViewState();
}

class _ManageIndividualCompetitionViewState
    extends State<ManageIndividualCompetitionView>
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
              'Individual Management',
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
            Tab(text: "Participants", icon: Icon(Icons.person_outline, size: 20)),
            Tab(text: "Settings", icon: Icon(Icons.tune_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _IndividualOverviewTab(competition: widget.competition),
          _ParticipantsListTab(competition: widget.competition),
          _IndividualSettingsTab(competition: widget.competition),
        ],
      ),
    );
  }
}

class _IndividualOverviewTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _IndividualOverviewTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          InfoCard(
            title: "Individual Capacity",
            items: [
              InfoRow(
                label: "Participants Joined",
                value: "${competition.participantsCount} / ${competition.maxParticipants}",
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

class _ParticipantsListTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _ParticipantsListTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    final participants = competition.participants ?? [];

    if (participants.isEmpty) {
      return Center(
        child: Text(
          "No participants joined yet.",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: participants.length,
      separatorBuilder: (_, __) => 12.vs,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: AppColors.primary),
              12.hs,
              Expanded(
                child: Text(
                  participant.name ?? 'Participant #${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${participant.points ?? 0} pts",
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

class _IndividualSettingsTab extends StatelessWidget {
  final CompetitionEntity competition;

  const _IndividualSettingsTab({required this.competition});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Individual Competition Settings",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

// =============================================================================
// REUSABLE HELPER COMPONENTS
// =============================================================================


