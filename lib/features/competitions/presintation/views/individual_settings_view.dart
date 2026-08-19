import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/manage_competition_state.dart';

class IndividualSettingsView extends StatefulWidget {
  final CompetitionEntity competition;

  const IndividualSettingsView({
    super.key,
    required this.competition,
  });

  @override
  State<IndividualSettingsView> createState() => _IndividualSettingsViewState();
}

class _IndividualSettingsViewState extends State<IndividualSettingsView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _basePointsController;
  late final TextEditingController _penaltyPointsController;

  late String _selectedCategory;
  late bool _isPublicAccess;

  late DateTime _startDate;
  late DateTime _endDate;

  late bool _leaderboardVisibility;
  late bool _rankChangeAlerts;
  late bool _milestoneAlerts;

  late List<String> _multipliers;

  final List<String> _categories = [
    'Technology',
    'Data Science',
    'AI & ML',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final comp = widget.competition;

    _nameController = TextEditingController(text: comp.name);
    _descController = TextEditingController(text: comp.description);
    
    // Numeric input controllers formatted cleanly
    _basePointsController = TextEditingController(
      text: comp.basePoints.toStringAsFixed(comp.basePoints.truncateToDouble() == comp.basePoints ? 0 : 2),
    );
    _penaltyPointsController = TextEditingController(
      text: comp.penaltyPoints.toStringAsFixed(comp.penaltyPoints.truncateToDouble() == comp.penaltyPoints ? 0 : 2),
    );

    _selectedCategory = _categories.contains(comp.category)
        ? comp.category
        : _categories.first;

    _isPublicAccess = comp.isPublic;

    _startDate = comp.startDate;
    _endDate = comp.endDate;

    _leaderboardVisibility = comp.leaderboardVisibility;
    _rankChangeAlerts = comp.rankChangeAlerts;
    _milestoneAlerts = comp.milestoneAlerts;

    _multipliers = List<String>.from(comp.multipliers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePointsController.dispose();
    _penaltyPointsController.dispose();
    super.dispose();
  }

  int get _durationInDays {
    final difference = _endDate.difference(_startDate).inDays;
    return difference >= 0 ? difference : 0;
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Colors.black,
              surface: Color(0xFF161925),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _onSaveChanges() {
    final basePoints = double.tryParse(_basePointsController.text.trim()) ?? widget.competition.basePoints;
    final penaltyPoints = double.tryParse(_penaltyPointsController.text.trim()) ?? widget.competition.penaltyPoints;

    final updatedEntity = widget.competition.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      isPublic: _isPublicAccess,
      startDate: _startDate,
      endDate: _endDate,
      basePoints: basePoints,
      penaltyPoints: penaltyPoints,
      leaderboardVisibility: _leaderboardVisibility,
      rankChangeAlerts: _rankChangeAlerts,
      milestoneAlerts: _milestoneAlerts,
      multipliers: _multipliers,
    );

    context.read<ManageCompetitionCubit>().updateCompetition(updatedEntity);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFC107);
    const darkBg = Color(0xFF0D0F17);
    const cardBg = Color(0xFF161925);

    return BlocListener<ManageCompetitionCubit, ManageCompetitionState>(
      listener: (context, state) {
        if (state.status == ManageCompetitionStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.status == ManageCompetitionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update settings.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PTOOK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${widget.competition.name} Settings',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Competition\nSettings',
                style: TextStyle(
                  color: primaryGold,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),

              // 1. GENERAL INFO CARD
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.settings_outlined, 'General Info'),
                    const SizedBox(height: 16),
                    _buildLabel('Competition Name'),
                    _buildTextField(_nameController),
                    const SizedBox(height: 14),
                    _buildLabel('Description'),
                    _buildTextField(_descController, maxLines: 3),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Category'),
                              _buildDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPublicAccessToggle(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. SCHEDULE CARD
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.calendar_today_outlined, 'Schedule'),
                    const SizedBox(height: 16),
                    _buildLabel('Start Date'),
                    _buildDateField(
                      _formatDate(_startDate),
                      onTap: () => _selectDate(context, isStartDate: true),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('End Date'),
                    _buildDateField(
                      _formatDate(_endDate),
                      onTap: () => _selectDate(context, isStartDate: false),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined, color: Colors.white54, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Duration: $_durationInDays Days',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. ACCESS CONTROL CARD
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.shield_outlined, 'Access Control'),
                    const SizedBox(height: 16),
                    _buildAccessTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Manage Moderators',
                      subtitle: '3 Active Mods',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _buildAccessTile(
                      icon: Icons.person_add_outlined,
                      title: 'Join Requests',
                      subtitle: '12 Pending',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. SCORING LOGIC CARD (TEXT INPUT FIELDS)
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.flag_outlined, 'Scoring Logic'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Base Points per Win'),
                              _buildTextField(
                                _basePointsController,
                                isNumber: true,
                                prefixIcon: Icons.add_circle_outline,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Penalty Points'),
                              _buildTextField(
                                _penaltyPointsController,
                                isNumber: true,
                                prefixIcon: Icons.remove_circle_outline,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Point Multipliers'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._multipliers.map(
                          (m) => Chip(
                            backgroundColor: cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.white24),
                            ),
                            label: Text(m, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                            onDeleted: () {
                              setState(() => _multipliers.remove(m));
                            },
                          ),
                        ),
                        ActionChip(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.white38),
                          ),
                          avatar: const Icon(Icons.add, size: 16, color: Colors.white70),
                          label: const Text('Add', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. VISIBILITY & ALERTS CARD
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.visibility_outlined, 'Visibility & Alerts'),
                    const SizedBox(height: 12),
                    _buildSwitchRow(
                      title: 'Leaderboard Visibility',
                      subtitle: 'Allow participants to view standings',
                      value: _leaderboardVisibility,
                      onChanged: (v) => setState(() => _leaderboardVisibility = v),
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _buildSwitchRow(
                      title: 'Rank Change Alerts',
                      subtitle: 'Notify users when they move up/down',
                      value: _rankChangeAlerts,
                      onChanged: (v) => setState(() => _rankChangeAlerts = v),
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    _buildSwitchRow(
                      title: 'Milestone Alerts',
                      subtitle: 'Celebrate point thresholds',
                      value: _milestoneAlerts,
                      onChanged: (v) => setState(() => _milestoneAlerts = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SAVE CHANGES BUTTON
              BlocBuilder<ManageCompetitionCubit, ManageCompetitionState>(
                builder: (context, state) {
                  final isLoading = state.status == ManageCompetitionStatus.actionInProgress;

                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : _onSaveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.save_outlined, color: Colors.black),
                    label: Text(
                      isLoading ? 'Saving...' : 'Save Changes',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161925),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(signed: true, decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0D0F17),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white38, size: 18) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
      ),
    );
  }

  Widget _buildDateField(String dateStr, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F17),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          dropdownColor: const Color(0xFF161925),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildPublicAccessToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Public\nAccess',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: _isPublicAccess,
            activeColor: const Color(0xFFFFC107),
            onChanged: (v) => setState(() => _isPublicAccess = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F17),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFFFFC107),
          onChanged: onChanged,
        ),
      ],
    );
  }
}