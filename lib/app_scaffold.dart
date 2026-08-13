import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart'; // 👈 1. Import SearchCompetitionCubit
import 'package:ptook/features/competitions/presintation/views/competition_search_view.dart';
import 'package:ptook/features/competitions/presintation/views/create_competition_view.dart';
import 'package:ptook/features/home/presintation/views/home_view.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),

      // 👈 2. Wrap CompetitionSearchView with BlocProvider
      BlocProvider<SearchCompetitionCubit>(
        create: (context) => sl<SearchCompetitionCubit>(),
        child: const CompetitionSearchView(),
      ),

      BlocProvider<CreateCompetitionCubit>(
        create: (context) => sl<CreateCompetitionCubit>(),
        child: CreateCompetitionView(
          onSuccess: () => _onItemTapped(0),
        ),
      ),
      const _PlaceholderScreen(title: 'Activity View'),
      const _PlaceholderScreen(title: 'Profile View'),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true, // Enables transparency/floating under bottom nav bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Center '+' Floating Action Button matching exact UI
  Widget _buildCenterFloatingActionButton() {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.only(top: 18),
      child: FittedBox(
        child: FloatingActionButton(
          elevation: 6,
          highlightElevation: 10,
          backgroundColor: const Color(0xFF14161D), // Dark inner fill
          shape: const CircleBorder(
            side: BorderSide(
              color: AppColors.primary, // Gold stroke border
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

  /// Curved Floating Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: "HOME",
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                // 2. Explore
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 1,
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: "EXPLORE",
                    onTap: () => _onItemTapped(1),
                  ),
                ),
                // Gap reserved for Center Docked FAB
                const SizedBox(width: 60),
                // 3. Activity
                Expanded(
                  child: _BottomNavItem(
                    isSelected: _selectedIndex == 3,
                    icon: Icons.auto_graph_outlined,
                    activeIcon: Icons.auto_graph_rounded,
                    label: "ACTIVITY",
                    onTap: () => _onItemTapped(3),
                  ),
                ),
                // 4. Profile
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
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = const Color(0xFF8A8F9E);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icon
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 22,
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Active Indicator Pill Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 18 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}