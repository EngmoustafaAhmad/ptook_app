import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/activity/presintation/cubit/activity_cubit.dart';
import 'package:ptook/features/activity/presintation/views/activity_view.dart';
import 'package:ptook/features/create_competition/presintation/cubits/create_competition_cubit.dart';
import 'package:ptook/features/create_competition/presintation/pages/create_competition_view.dart';
import 'package:ptook/features/home/presintation/views/home_view.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/profile/presintation/views/profile_view.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/pages/search_competition_page.dart';
import 'package:ptook/features/shared/presintation/widgets/app_drawer.dart';
import 'package:ptook/features/shared/presintation/widgets/app_top_bar.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/pages/saved_competitions_view.dart';

class AppScaffold extends StatefulWidget {
  final String userId;

  const AppScaffold({
    super.key,
    required this.userId,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSavedCompetitions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<CompetitionHomeCubit>(
          create: (context) => sl<CompetitionHomeCubit>(),
          child: SavedCompetitionsView(userId: widget.userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (_) => sl<ProfileCubit>()..streamUserProfile(widget.userId),
        ),
        BlocProvider<SearchCompetitionCubit>(
          create: (_) => sl<SearchCompetitionCubit>(),
        ),
        BlocProvider<CreateCompetitionCubit>(
          create: (_) => sl<CreateCompetitionCubit>(),
        ),
        BlocProvider<ActivityCubit>(
          create: (_) => sl<ActivityCubit>()..fetchUserActivities(widget.userId),
        ),
        BlocProvider<CompetitionHomeCubit>(
          create: (_) => sl<CompetitionHomeCubit>()
            ..fetchSavedCompetitions(userId: widget.userId),
        ),
      ],
      child: Builder(
        builder: (context) {
          final pages = [
            const HomeView(),
            const CompetitionSearchView(showBackButton: false),
            CreateCompetitionView(
              onSuccess: () => _onItemTapped(0),
            ),
            ActivityView(userId: widget.userId),
            ProfileView(userId: widget.userId),
          ];

          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = (state is ProfileLoaded) ? state.user : null;
              final dynamicName = user?.name ?? 'User';
              final dynamicEmail = user?.email ?? '';

              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: AppColors.background,
                drawer: AppDrawer(
                  userId: widget.userId,
                  userName: dynamicName,
                  userEmail: dynamicEmail,
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      if (_selectedIndex == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: AppTopBar(
                            user: user,
                            onMenuPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            onBookmarkPressed: _navigateToSavedCompetitions,
                          ),
                        ),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  ),
                ),
                extendBody: true,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: _buildCenterFloatingActionButton(),
                bottomNavigationBar: _buildBottomNavigationBar(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCenterFloatingActionButton() {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.only(top: 18),
      child: FittedBox(
        child: FloatingActionButton(
          elevation: 6,
          highlightElevation: 10,
          backgroundColor: const Color(0xFF14161D),
          shape: const CircleBorder(
            side: BorderSide(
              color: AppColors.primary,
              width: 2.0,
            ),
          ),
          onPressed: () => _onItemTapped(2),
          child: const Icon(
            Icons.add,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 68,
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: "HOME",
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 1,
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: "EXPLORE",
                    onTap: () => _onItemTapped(1),
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 3,
                    icon: Icons.auto_graph_outlined,
                    activeIcon: Icons.auto_graph_rounded,
                    label: "ACTIVITY",
                    onTap: () => _onItemTapped(3),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 4,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: "PROFILE",
                    onTap: () => _onItemTapped(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.isSelected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = AppColors.primary;
    const Color inactiveColor = Color(0xFF8A8F9E);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}