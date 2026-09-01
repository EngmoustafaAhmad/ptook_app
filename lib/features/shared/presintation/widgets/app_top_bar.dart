import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';

class AppTopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onBookmarkPressed;
  final int notificationCount;

  const AppTopBar({
    super.key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onBookmarkPressed,
    this.notificationCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Icon Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber, size: 22),
            onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),

        // Brand Logo Center
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
            8.hs,
            const Text(
              "PTOOK",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        // Right Actions (Saved Competitions + Notifications)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bookmark Icon Button
            Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: IconButton(
                icon: const Icon(Icons.bookmark_outline_rounded,
                    color: Colors.amber, size: 22),
                onPressed: onBookmarkPressed,
              ),
            ),

            // Notification Icon with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_outlined,
                        color: Colors.amber, size: 22),
                    onPressed: onNotificationPressed,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}