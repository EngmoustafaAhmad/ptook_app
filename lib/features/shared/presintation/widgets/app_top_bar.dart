// features/shared/presentation/widgets/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/shared/domain/entities/participant_entity.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';

class AppTopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBookmarkPressed;
  
  /// Optional explicit entities
  final UserEntity? user;
  final ParticipantEntity? participant;
  
  /// Explicit override or fallback values
  final int? totalPowerOverride;
  final int maxPower;

  const AppTopBar({
    super.key,
    this.onMenuPressed,
    this.onBookmarkPressed,
    this.user,
    this.participant,
    this.totalPowerOverride,
    this.maxPower = 3,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        // ⚡ Priority Resolution:
        // 1. Explicit manual integer override
        // 2. ParticipantEntity power (if provided in competition context)
        // 3. UserEntity passed explicitly
        // 4. UserEntity from active ProfileCubit state
        // 5. Default fallback to 3
        int effectivePower = totalPowerOverride ??
            participant?.totalPower ??
            user?.totalPower ??
            (profileState is ProfileLoaded ? profileState.user.totalPower : 3);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Actions: Drawer Menu + Gauge Power Indicator
            Row(
              mainAxisSize: MainAxisSize.min,
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
                    icon: const Icon(Icons.menu, color: Colors.amber, size: 22),
                    onPressed: onMenuPressed ??
                        () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),

                // ⚡ Dynamic Power Gauge
                _buildPowerBolts(effectivePower),
              ],
            ),

            // Right Actions: Saved Competitions Bookmark
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.bookmark_border_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
                onPressed: onBookmarkPressed,
              ),
            ),
          ],
        );
      },
    );
  }

  /// ⚡ Builds dynamic power gauge with filled and unfilled bolt icons
  Widget _buildPowerBolts(int power) {
    final currentPower = power.clamp(0, maxPower);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxPower, (index) {
        final isFilled = index < currentPower;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            isFilled ? Icons.bolt_rounded : Icons.bolt_outlined,
            color: isFilled ? Colors.amber : Colors.white24,
            size: 26,
          ),
        );
      }),
    );
  }
} 