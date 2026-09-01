import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';

class ManagementAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String status;
  final bool isFinished;
  final VoidCallback onSettingsTap;
  final TabBar? bottomTabBar;

  const ManagementAppBar({
    super.key,
    required this.title,
    required this.status,
    required this.isFinished,
    required this.onSettingsTap,
    this.bottomTabBar,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottomTabBar?.preferredSize.height ?? 0.0) + 8.0,
      );

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isFinished ? const Color(0xFFFFB703) : const Color(0xFF00E676);
    final statusText = isFinished ? 'FINISHED' : status.toUpperCase();

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: Colors.white, size: 20),
              onPressed: onSettingsTap,
            ),
          ),
        ),
      ],
      bottom: bottomTabBar != null
          ? PreferredSize(
              preferredSize: bottomTabBar!.preferredSize,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: bottomTabBar,
              ),
            )
          : null,
    );
  }
}