import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/pages/saved_competitions_view.dart';

class AppDrawer extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String? avatarUrl;

  const AppDrawer({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFD700);
    const cardBackground = Color(0xFF1E1E1E);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          // -----------------------------------------------------------------
          // HEADER: User Profile Info
          // -----------------------------------------------------------------
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: cardBackground,
              border: Border(
                bottom: BorderSide(color: Colors.white10),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: primaryGold,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),

          // -----------------------------------------------------------------
          // NAVIGATION ITEMS
          // -----------------------------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'My Competitions',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to My Competitions
                  },
                ),
                
                _buildDrawerItem(
                  icon: Icons.bookmark_border_rounded,
                  iconColor: primaryGold,
                  title: 'Saved Competitions',
                  trailingBadge: 'Favorites',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<CompetitionHomeCubit>(
                          create: (context) => sl<CompetitionHomeCubit>(),
                          child: SavedCompetitionsView(userId: currentUserId),
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.groups_outlined,
                  title: 'My Teams',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Teams
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Global Rankings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Rankings
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white10),
                ),

                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Settings
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Help
                  },
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // FOOTER: Logout Button
          // -----------------------------------------------------------------
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Trigger logout action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    String? trailingBadge,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailingBadge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded,
              color: Colors.white24, size: 20),
      onTap: onTap,
    );
  }
}