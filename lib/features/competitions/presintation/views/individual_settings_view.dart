import 'package:flutter/material.dart';

class IndividualSettingsView extends StatefulWidget {
  const IndividualSettingsView({super.key});

  @override
  State<IndividualSettingsView> createState() => _IndividualSettingsViewState();
}

class _IndividualSettingsViewState extends State<IndividualSettingsView> {
  // Form Controllers & State
  final TextEditingController _nameController =
      TextEditingController(text: 'ML Phase One');
  final TextEditingController _descController = TextEditingController(
    text:
        'Quarterly machine learning competition focused on predictive modeling and algorithmic optimization.',
  );

  String _selectedCategory = 'Technology';
  bool _isPublicAccess = true;

  double _basePoints = 100;
  double _penaltyPoints = -15;

  bool _leaderboardVisibility = true;
  bool _rankChangeAlerts = true;
  bool _milestoneAlerts = true;

  final List<String> _multipliers = ['Streak x1.5', 'Underdog x2.0'];

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFC107);
    const darkBg = Color(0xFF0D0F17);
    const cardBg = Color(0xFF161925);

    return Scaffold(
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
          children: const [
            Text(
              'PTOOK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'ML Phase One Settings',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header Title
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
                  _buildDateField('11/01/2024'),
                  const SizedBox(height: 14),
                  _buildLabel('End Date'),
                  _buildDateField('12/15/2024'),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_outlined, color: Colors.white54, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Duration: 45 Days',
                          style: TextStyle(color: Colors.white, fontSize: 14),
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

            // 4. SCORING LOGIC CARD
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.flag_outlined, 'Scoring Logic'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Base Points per Win'),
                      Text(
                        '${_basePoints.round()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _basePoints,
                    min: 0,
                    max: 500,
                    activeColor: primaryGold,
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _basePoints = v),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Penalty Points'),
                      Text(
                        '${_penaltyPoints.round()}',
                        style: const TextStyle(
                          color: Color(0xFFFF8A80),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _penaltyPoints,
                    min: -50,
                    max: 0,
                    activeColor: const Color(0xFFFF8A80),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _penaltyPoints = v),
                  ),
                  const SizedBox(height: 12),
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
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              icon: const Icon(Icons.save_outlined, color: Colors.black),
              label: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
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

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0D0F17),
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

  Widget _buildDateField(String dateStr) {
    return Container(
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
          items: ['Technology', 'Data Science', 'AI & ML', 'General']
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