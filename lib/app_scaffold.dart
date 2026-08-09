import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/competitions/presintation/bloc/create_competition_cubit.dart';
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
    // Cache the page list to keep Cubit/Widget instances alive across re-renders
    _pages = [
      const HomeView(),
      BlocProvider<CreateCompetitionCubit>(
        create: (context) => sl<CreateCompetitionCubit>(),
        child: CreateCompetitionView(
          onSuccess: () => _onItemTapped(0),
        ),
      ),
      const _ProfilePlaceholder(),
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
    final bool isCreateSelected = _selectedIndex == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAnimatedCreateButton(isCreateSelected),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAnimatedCreateButton(bool isCreateSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        height: isCreateSelected ? 66 : 56,
        width: isCreateSelected ? 66 : 56,
        margin: EdgeInsets.only(bottom: isCreateSelected ? 12 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isCreateSelected
                ? [AppColors.primary, Colors.amber]
                : [Colors.amber, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isCreateSelected ? 0.45 : 0.2),
              blurRadius: isCreateSelected ? 16 : 8,
              offset: Offset(0, isCreateSelected ? 6 : 3),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: AppColors.background,
          size: isCreateSelected ? 32 : 28,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _BottomNavItem(
                  isSelected: _selectedIndex == 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: "Home",
                  onTap: () => _onItemTapped(0),
                ),
              ),
              const SizedBox(width: 48), // Gap for the center docked FloatingActionButton
              Expanded(
                child: _BottomNavItem(
                  isSelected: _selectedIndex == 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: "Profile",
                  onTap: () => _onItemTapped(2),
                ),
              ),
            ],
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
    final Color color = isSelected ? AppColors.primary : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: isSelected ? 26 : 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              letterSpacing: 0.3,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "👤 Profile View",
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}