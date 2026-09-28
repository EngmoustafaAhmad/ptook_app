import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart' as di;
import 'package:ptook/services/reward_ad_service.dart';

class RewardAdDialog extends StatefulWidget {
  final String userId;
  final VoidCallback onPowerEarned;

  const RewardAdDialog({
    super.key,
    required this.userId,
    required this.onPowerEarned,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required VoidCallback onPowerEarned,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RewardAdDialog(
        userId: userId,
        onPowerEarned: onPowerEarned,
      ),
    );
  }

  @override
  State<RewardAdDialog> createState() => _RewardAdDialogState();
}

class _RewardAdDialogState extends State<RewardAdDialog> {
  late final RewardAdService _adService;
  bool _isAdReady = false;
  bool _isGrantingReward = false; // Prevents duplicate triggers

  @override
  void initState() {
    super.initState();
    // Inject singleton service from GetIt
    _adService = di.sl<RewardAdService>();

    if (kIsWeb) {
      _isAdReady = true;
    } else {
      _adService.loadAd(
        onLoaded: () {
          if (mounted) {
            setState(() => _isAdReady = true);
          }
        },
      );
    }
  }

  void _watchAd() {
    if (_isGrantingReward) return;

    if (kIsWeb) {
      _grantReward();
      return;
    }

    _adService.showAd(
      context: context,
      onUserEarnedReward: _grantReward,
    );
  }

  Future<void> _grantReward() async {
    if (_isGrantingReward) return;

    setState(() {
      _isGrantingReward = true;
    });

    try {
      if (!mounted) return;

      // 1. Dismiss the dialog safely
      Navigator.of(context).pop();

      // 2. Trigger PowerGuard callback (atomic reward + consume + action)
      widget.onPowerEarned();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGrantingReward = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Action failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.bolt_outlined, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text(
            "Out of Power!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        "You need at least ⚡1 Power Unit to perform this action. Watch an ad to claim +1 Power Unit!",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: _isGrantingReward ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton.icon(
          onPressed: (_isAdReady && !_isGrantingReward) ? _watchAd : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: _isGrantingReward
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Icon(Icons.ondemand_video_rounded, color: Colors.black),
          label: Text(
            _isGrantingReward
                ? "Processing..."
                : (_isAdReady ? "Watch Ad (+1 ⚡)" : "Loading Ad..."),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}