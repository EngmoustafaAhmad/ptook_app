import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/activity/presintation/cubit/activity_cubit.dart';
import 'package:ptook/features/activity/presintation/views/activity_view.dart';
import 'package:ptook/features/auth/presintation/views/login_view.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/profile/presintation/cubit/update_profile/update_profile_cubit.dart';
import 'package:ptook/features/profile/presintation/views/settings_profile_view.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/shared/presintation/pages/help_support_view.dart';
import 'package:ptook/features/shared/presintation/pages/my_competitions_view.dart';
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? userId;

    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final UserEntity? realUser = (state is ProfileLoaded) ? state.user : null;

          final displayName = realUser?.name ?? userName;
          final displayEmail = (realUser?.email.isNotEmpty == true) ? realUser!.email : userEmail;
          final displayAvatar = realUser?.avatarUrl ?? avatarUrl;
          final initials = realUser?.initials ?? (displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U');

          return Column(
            children: [
              // HEADER SECTION
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: cardBackground,
                  border: Border(
                    bottom: BorderSide(color: Colors.white10),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: primaryGold,
                  backgroundImage: (displayAvatar != null && displayAvatar.isNotEmpty)
                      ? CachedNetworkImageProvider(displayAvatar)
                      : null,
                  child: (displayAvatar == null || displayAvatar.isEmpty)
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
                accountName: Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                accountEmail: Text(
                  displayEmail,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),

              // NAVIGATION LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.emoji_events_outlined,
                      title: 'My Competitions',
                      trailingBadge: realUser != null && realUser.joinedCompetitionsCount > 0
                          ? '${realUser.joinedCompetitionsCount}'
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyCompetitionsView(userId: currentUserId),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.bookmark_border_rounded,
                      iconColor: primaryGold,
                      title: 'Saved Arenas',
                      trailingBadge: realUser != null && realUser.savedCompetitionsCount > 0
                          ? '${realUser.savedCompetitionsCount}'
                          : null,
                      onTap: () {
                        Navigator.pop(context);
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
                      icon: Icons.auto_graph_rounded,
                      title: 'Activity Feed',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider<ActivityCubit>(
                              create: (context) => sl<ActivityCubit>()..fetchUserActivities(currentUserId),
                              child: ActivityView(userId: currentUserId),
                            ),
                          ),
                        );
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
                        if (realUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider<UpdateProfileCubit>(
                                create: (context) => sl<UpdateProfileCubit>(),
                                child: SettingsProfileView(currentUser: realUser),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // FOOTER / LOGOUT
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  // 1. Close drawer first
                  Navigator.pop(context);

                  // 2. Stop active Firestore profile stream safely (do NOT call .close())
                  context.read<ProfileCubit>().stopStreaming();

                  // 3. Perform Firebase Sign Out
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  // 4. Wipe navigation stack completely so no previous views keep listening
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                },
              )
            ],
          );
        },
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
          : const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 20,
            ),
      onTap: onTap,
    );
  }
}