import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';
import 'package:ptook/features/competitions/presintation/views/individual_settings_view.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';

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
    // Resets Cubit state/messages when entering the view
    context.read<ManageCompetitionCubit>().resetState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
      listener: (context, state) {
        // Handle successful deletion: navigate back and notify parent list
        if (state.status == ManageCompetitionStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competition deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }

        // Handle successful competition completion
        if (state.status == ManageCompetitionStatus.finished) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Competition finished successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Handle server/network errors gracefully
        if (state.status == ManageCompetitionStatus.error &&
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
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Color(0xFFFFC107)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndividualSettingsView(),
                    ),
                  );
                },
              ),
            ],
            bottom: const TabBar(
              indicatorColor: Color(0xFFFFC107),
              indicatorWeight: 3,
              labelColor: Color(0xFFFFC107),
              unselectedLabelColor: Colors.white60,
              labelStyle:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: [
                Tab(text: 'Preview'),
                Tab(text: 'Edit'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _PreviewTabView(),
              _EditTabView(),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. PREVIEW TAB VIEW
// -----------------------------------------------------------------------------
class _PreviewTabView extends StatelessWidget {
  const _PreviewTabView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
      builder: (context, state) {
        if (state.status == ManageCompetitionStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        // Defensive Guard: Avoid reading properties if document was deleted
        if (state.status == ManageCompetitionStatus.deleted ||
            state.competition == null) {
          return const Center(
            child: Text(
              'Competition no longer exists.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final currentComp = state.competition;
        final participants = state.participants;

        final totalPoints = participants.fold<int>(
          0,
          (sum, item) => sum + item.points,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Competition Overview Card
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Competition Overview',
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.3,
                      children: [
                        _OverviewItem(
                          title: 'TOTAL PARTICIPANTS',
                          value: '${currentComp?.maxParticipants ?? 0}',
                        ),
                        _OverviewItem(
                          title: 'JOINED',
                          value: '${participants.length}',
                          total: '/${currentComp?.maxParticipants ?? 0}',
                        ),
                        _OverviewItem(
                          title: 'TOTAL POINTS',
                          value: '$totalPoints',
                        ),
                        _StatusItem(
                          title: 'STATUS',
                          status: currentComp?.status ?? 'Active',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Leaderboard Preview (Top 3)
              _buildCardContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Color(0xFFFFC107),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Leaderboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View Full Ranking >',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    if (participants.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No participants yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(
                          participants.length > 3 ? 3 : participants.length,
                          (index) {
                            final participant = participants[index];
                            return _LeaderboardRow(
                              rank: '#${index + 1}',
                              name: participant.name,
                              points: '${participant.points} pts',
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Participants List
              const Text(
                'Participant Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (participants.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No participants joined yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return _ParticipantCard(
                      rank: '#${index + 1}',
                      participant: participant,
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Admin Controls
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Color(0xFFFFC107),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Administrative Actions',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showConfirmationDialog(
                        context,
                        title: 'Finish Competition',
                        content:
                            'Are you sure you want to finish this competition?',
                        onConfirm: () => context
                            .read<ManageCompetitionCubit>()
                            .finishCompetition(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(
                        Icons.emoji_events,
                        color: Colors.black,
                        size: 20,
                      ),
                      label: const Text(
                        'FINISH COMPETITION',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showConfirmationDialog(
                        context,
                        title: 'Delete Competition',
                        content:
                            'This action is permanent and cannot be undone.',
                        onConfirm: () => context
                            .read<ManageCompetitionCubit>()
                            .deleteCompetition(),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      label: const Text(
                        'DELETE COMPETITION',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161925),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child:
                const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PARTICIPANT CARD WITH AVATAR INTEGRATION
// -----------------------------------------------------------------------------
class _ParticipantCard extends StatelessWidget {
  final String rank;
  final ParticipantEntity participant;

  const _ParticipantCard({
    required this.rank,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // Rank Indicator
          Text(
            rank,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),

          // Participant Avatar Component
          _ParticipantAvatarItem(participant: participant),
          const SizedBox(width: 12),

          // Full Name
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Points Display
          Text(
            '${participant.points} pts',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PARTICIPANT AVATAR ITEM
// -----------------------------------------------------------------------------
class _ParticipantAvatarItem extends StatelessWidget {
  final ParticipantEntity participant;

  const _ParticipantAvatarItem({required this.participant});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = participant.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white10,
          child: hasAvatar
              ? ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitials(participant.initials),
                  ),
                )
              : _buildInitials(participant.initials),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF161925),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(String initials) {
    return Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. EDIT TAB VIEW
// -----------------------------------------------------------------------------
class _EditTabView extends StatelessWidget {
  const _EditTabView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
      builder: (context, state) {
        if (state.status == ManageCompetitionStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        if (state.status == ManageCompetitionStatus.deleted ||
            state.competition == null) {
          return const SizedBox.shrink();
        }

        final participants = state.participants;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Participant Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (participants.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No participants to edit.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];

                    return _EditableParticipantCard(
                      participant: participant,
                      rank: '#${index + 1}',
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// EDITABLE PARTICIPANT CARD WITH PLUS, MINUS, DIRECT INPUT & SUBMIT CHECK
// -----------------------------------------------------------------------------
class _EditableParticipantCard extends StatefulWidget {
  final ParticipantEntity participant;
  final String rank;

  const _EditableParticipantCard({
    super.key,
    required this.participant,
    required this.rank,
  });

  @override
  State<_EditableParticipantCard> createState() =>
      _EditableParticipantCardState();
}

class _EditableParticipantCardState extends State<_EditableParticipantCard> {
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    // Default initial value set to '1' for fast quick-add
    _pointsController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _increment() {
    final currentValue = int.tryParse(_pointsController.text) ?? 0;
    _pointsController.text = (currentValue + 1).toString();
  }

  void _decrement() {
    final currentValue = int.tryParse(_pointsController.text) ?? 0;
    _pointsController.text = (currentValue - 1).toString();
  }

  void _submitPoints() {
    final int? addedPoints = int.tryParse(_pointsController.text);
    if (addedPoints == null || addedPoints == 0) return;

    context.read<ManageCompetitionCubit>().updateParticipantPoints(
          participantId: widget.participant.id,
          addedPoints: addedPoints,
        );

    // Reset default back to '1' after submission
    _pointsController.text = '1';
  }

  void _deleteParticipant() {
    context
        .read<ManageCompetitionCubit>()
        .removeParticipant(widget.participant.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF161925),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Rank
            Text(
              widget.rank,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),

            // Avatar placeholder / Initials
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.participant.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Name & Current Points
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.participant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.participant.points} pts',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Controls Box: [ - ] [ Value Field ] [ + ] [ ✓ ]
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minus Button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onPressed: _decrement,
                  ),

                  // Direct Input TextField
                  SizedBox(
                    width: 36,
                    child: TextField(
                      controller: _pointsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Plus Button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onPressed: _increment,
                  ),

                  const SizedBox(width: 2),

                  // Check / Confirm Button (Pushes Points)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 28),
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    onPressed: _submitPoints,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Delete Participant
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: _deleteParticipant,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE HELPER WIDGETS
// -----------------------------------------------------------------------------
Widget _buildCardContainer({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF161925),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withAlpha(20)),
    ),
    child: child,
  );
}

class _OverviewItem extends StatelessWidget {
  final String title;
  final String value;
  final String? total;

  const _OverviewItem({required this.title, required this.value, this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              if (total != null)
                TextSpan(
                  text: total,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final String status;

  const _StatusItem({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 3, backgroundColor: Colors.green),
              const SizedBox(width: 6),
              Text(
                status,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final String rank;
  final String name;
  final String points;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            rank,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 16, backgroundColor: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}