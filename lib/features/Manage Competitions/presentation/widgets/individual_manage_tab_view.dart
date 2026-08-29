import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_cubit.dart';
import 'package:ptook/features/Manage%20Competitions/presentation/cubits/participant_management/participant_management_state.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';

class IndividualManageTabView extends StatelessWidget {
  const IndividualManageTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParticipantManagementCubit, ParticipantManagementState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
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
                    return _EditableParticipantCard(
                      participant: participants[index],
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

class _EditableParticipantCard extends StatefulWidget {
  final ParticipantEntity participant;
  final String rank;

  const _EditableParticipantCard({
    required this.participant,
    required this.rank,
  });

  @override
  State<_EditableParticipantCard> createState() =>
      __EditableParticipantCardState();
}

class __EditableParticipantCardState extends State<_EditableParticipantCard> {
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
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

    final String competitionId = widget.participant.competitionId;
    final String participantId = widget.participant.id.isNotEmpty
        ? widget.participant.id
        : widget.participant.userId;

    if (competitionId.isEmpty || participantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid competition or participant ID.')),
      );
      return;
    }

    context.read<ParticipantManagementCubit>().updateParticipantPoints(
          competitionId: competitionId,
          participantId: participantId,
          addedPoints: addedPoints,
        );

    _pointsController.text = '1';
  }

  void _deleteParticipant() {
    context.read<ParticipantManagementCubit>().removeParticipant(
          competitionId: widget.participant.competitionId,
          participantId: widget.participant.id,
        );
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
            Text(
              widget.rank,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            _ParticipantAvatarItem(participant: widget.participant),
            const SizedBox(width: 10),
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