import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/shared/presintation/widgets/reward_ad_dialog.dart';

class PowerGuard {
  static Future<void> executeWithPowerCheck({
    required BuildContext context,
    required String userId,
    required Future<void> Function() onPowerAvailable,
  }) async {
    final profileCubit = context.read<ProfileCubit>();
    var state = profileCubit.state;

    if (state is! ProfileLoaded) {
      await profileCubit.getProfile(userId);
      state = profileCubit.state;
    }

    int currentPower = 0;
    if (state is ProfileLoaded) {
      currentPower = state.user.totalPower;
    }

    if (currentPower > 0) {
      // 1️⃣ User has power -> Consume 1 unit and proceed
      final success = await profileCubit.consumePower(userId);
      if (success) {
        await onPowerAvailable();
      }
    } else {
      // 2️⃣ Power is 0 -> Trigger Reward Ad Dialog safely
      if (!context.mounted) return;

      RewardAdDialog.show(
        context,
        userId: userId,
        onPowerEarned: () async {
          // ⚡ Atomically grant and consume the reward power without race conditions
          final success = await profileCubit.rewardAndConsumePower(userId);
          if (success) {
            await onPowerAvailable();
          }
        },
      );
    }
  }
}