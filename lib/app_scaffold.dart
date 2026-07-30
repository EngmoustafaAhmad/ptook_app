// lib/app_scaffold.dart

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

  // 🎯 الأسلوب الأفضل لإدارة الصفحات دون تجميد الحالة أو التسبب في مشاكل التحديث
  List<Widget> _buildPages() {
    return [
      const HomeView(),
      BlocProvider<CreateCompetitionCubit>(
        create: (context) => sl<CreateCompetitionCubit>(),
        child: CreateCompetitionView(
          onSuccess: () => _onItemTapped(0),
        ),
      ),
      const Center(
        child: Text(
          "👤 Profile View", 
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // منع إعادة بناء الصفحة إذا تم الضغط على نفس التبويب النشط
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreateSelected = _selectedIndex == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      // استخدام IndexedStack للحفاظ على الـ Scroll State وحالة البيانات في كل صفحة
      body: IndexedStack(
        index: _selectedIndex,
        children: _buildPages(),
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
        height: isCreateSelected ? 68 : 58,
        width: isCreateSelected ? 68 : 58,
        margin: EdgeInsets.only(bottom: isCreateSelected ? 20 : 0),
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
              color: AppColors.primary.withOpacity(isCreateSelected ? 0.5 : 0.25),
              blurRadius: isCreateSelected ? 16 : 8,
              offset: Offset(0, isCreateSelected ? 6 : 3),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: AppColors.background,
          size: isCreateSelected ? 34 : 28,
        ),
      ),
    );
  }

  // 🏗️ بناء شريط التنقل السفلي بهندسة نظيفة ومتناسقة بصرياً
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildBottomNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: "Home",
                ),
              ),
              const SizedBox(width: 60), // مساحة أوسع ومحسوبة بدقة لراحة الزر العائم ومنع تداخله
              Expanded(
                child: _buildBottomNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: "Profile",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏗️ ويدجت العناصر الفردية للشريط السفلي مع إلغاء تأثيرات الـ Splash الزائدة لشكل أرقى
  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.primary : Colors.grey.shade500;

    return InkWell(
      onTap: () => _onItemTapped(index),
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
          const SizedBox(height: 4),
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