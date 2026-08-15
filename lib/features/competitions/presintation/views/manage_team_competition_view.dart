import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';


class ManageTeamCompetitionView extends StatelessWidget {
  final CompetitionEntity competition;

  const ManageTeamCompetitionView({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F17),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0F17),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
            builder: (context, state) {
              final title = state.competition?.name ?? competition.name;
              final status = state.competition?.status ?? competition.status;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      const CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                // Navigate to Competition Settings
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFC107),
            indicatorWeight: 3,
            labelColor: Color(0xFFFFC107),
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Manage'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TeamOverviewTabView(),
            _TeamManageTabView(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. OVERVIEW TAB VIEW
// -----------------------------------------------------------------------------
class _TeamOverviewTabView extends StatelessWidget {
  const _TeamOverviewTabView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('12', 'Teams', Icons.groups_outlined),
              const SizedBox(width: 8),
              _buildStatCard('120', 'Participants', Icons.person_outline),
              const SizedBox(width: 8),
              _buildStatCard('45', 'Days\nDuration', Icons.access_time),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Teams',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'View All Teams',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTeamRankCard(
            rank: '1',
            badgeColor: const Color(0xFFFFC107),
            teamName: 'Team Alpha',
            membersCount: '10 Members',
            points: '12,500 pts',
            progress: 0.85,
          ),
          const SizedBox(height: 12),
          _buildTeamRankCard(
            rank: '2',
            badgeColor: Colors.grey,
            teamName: 'Data Wolves',
            membersCount: '10 Members',
            points: '8,450 pts',
            progress: 0.60,
          ),
          const SizedBox(height: 12),
          _buildTeamRankCard(
            rank: '3',
            badgeColor: Colors.orangeAccent,
            teamName: 'Neural Nets',
            membersCount: '10 Members',
            points: '7,200 pts',
            progress: 0.45,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161925),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFC107), size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRankCard({
    required String rank,
    required Color badgeColor,
    required String teamName,
    required String membersCount,
    required String points,
    required double progress,
  }) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161925),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CircleAvatar(radius: 28, backgroundColor: Colors.white12),
              const SizedBox(height: 8),
              Text(teamName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(membersCount, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
              const SizedBox(height: 4),
              Text(points, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  color: const Color(0xFFFFC107),
                  backgroundColor: Colors.white10,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 12,
          backgroundColor: badgeColor,
          child: Text(rank, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MANAGE TAB VIEW
// -----------------------------------------------------------------------------
class _TeamManageTabView extends StatelessWidget {
  const _TeamManageTabView();

  void _showCreateTeamDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161925),
        title: const Text('Create New Team', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter team name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
            onPressed: () {
              final teamName = controller.text.trim();
              if (teamName.isNotEmpty) {
                // context.read<ManageCompetitionCubit>().createTeam(teamName);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Create Team Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Teams Management',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateTeamDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.add, color: Colors.black, size: 18),
                label: const Text(
                  'Create Team',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expanded Team Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161925),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.groups_outlined, color: Color(0xFFFFC107)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code Kings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('3 Members • 1,250 pts', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white54), onPressed: () {}),
                    const Icon(Icons.keyboard_arrow_up, color: Colors.white54),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),

                // Editable Member Rows with Direct Input & Controls
                _EditableMemberRow(
                  rank: '#1',
                  name: 'Ahmed Ali',
                  currentPoints: 850,
                  onAddPoints: (addedPoints) {
                    context.read<ManageCompetitionCubit>().updateParticipantPoints(
                          participantId: 'ahmed_id',
                          addedPoints: addedPoints,
                        );
                  },
                  onDelete: () {},
                ),
                _EditableMemberRow(
                  rank: '#2',
                  name: 'Omar Khaled',
                  currentPoints: 720,
                  onAddPoints: (addedPoints) {
                    context.read<ManageCompetitionCubit>().updateParticipantPoints(
                          participantId: 'omar_id',
                          addedPoints: addedPoints,
                        );
                  },
                  onDelete: () {},
                ),
                const SizedBox(height: 8),

                // Add Member Button
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    side: const BorderSide(color: Colors.white24, style: BorderStyle.solid),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white70, size: 16),
                  label: const Text('Add Member', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Collapsed Team Cards
          _buildCollapsedTeamCard('Null Pointers', '4 Members • 980 pts'),
          const SizedBox(height: 12),
          _buildCollapsedTeamCard('Widget Wizards', '2 Members • 620 pts'),
          const SizedBox(height: 24),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161925),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Danger Zone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('End Competition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('Stop allowing new points. Finalizes leaderboard.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<ManageCompetitionCubit>().finishCompetition(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('END COMPETITION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                const Text('Delete Competition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('Permanently remove this competition and all its data.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<ManageCompetitionCubit>().deleteCompetition(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  child: const Text('DELETE COMPETITION', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedTeamCard(String name, String details) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.groups_outlined, color: Colors.white54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(details, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white54), onPressed: () {}),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. EDITABLE MEMBER ROW WIDGET
// -----------------------------------------------------------------------------
class _EditableMemberRow extends StatefulWidget {
  final String rank;
  final String name;
  final int currentPoints;
  final Function(int addedPoints) onAddPoints;
  final VoidCallback onDelete;

  const _EditableMemberRow({
    required this.rank,
    required this.name,
    required this.currentPoints,
    required this.onAddPoints,
    required this.onDelete,
  });

  @override
  State<_EditableMemberRow> createState() => _EditableMemberRowState();
}

class _EditableMemberRowState extends State<_EditableMemberRow> {
  late TextEditingController _controller;
  int _pointDelta = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDelta(int value) {
    setState(() {
      _pointDelta = value < 0 ? 0 : value;
      _controller.text = '$_pointDelta';
    });
  }

  void _submitPoints() {
    if (_pointDelta <= 0) return;
    widget.onAddPoints(_pointDelta);
    setState(() {
      _pointDelta = 0;
      _controller.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            widget.rank,
            style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(radius: 14, backgroundColor: Colors.white24),
          const SizedBox(width: 8),
          
          // Member Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.currentPoints} pts',
                  style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11),
                ),
              ],
            ),
          ),

          // Point Adjuster Controls: [-] [Square Input] [+] [✓]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrement Button (-)
                InkWell(
                  onTap: () => _updateDelta(_pointDelta - 5),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.remove, color: Colors.white70, size: 14),
                  ),
                ),

                // Editable Square Input
                Container(
                  width: 38,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F17),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _pointDelta > 0 ? const Color(0xFFFFC107) : Colors.white24,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _pointDelta > 0 ? const Color(0xFFFFC107) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      setState(() {
                        _pointDelta = parsed;
                      });
                    },
                  ),
                ),

                // Increment Button (+)
                InkWell(
                  onTap: () => _updateDelta(_pointDelta + 5),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.add, color: Colors.white70, size: 14),
                  ),
                ),
                const SizedBox(width: 2),

                // Confirm Checkmark Button (Submits points)
                InkWell(
                  onTap: _submitPoints,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _pointDelta > 0 ? Colors.green.withAlpha(40) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.check,
                      color: _pointDelta > 0 ? Colors.green : Colors.white38,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Delete Member Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}