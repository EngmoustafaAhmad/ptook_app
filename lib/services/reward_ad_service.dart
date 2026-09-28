import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdService {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  static const String _productionAndroidAdUnitId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const String _testAndroidAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  String get adUnitId {
    if (kIsWeb) return '';
    if (kDebugMode || _productionAndroidAdUnitId.contains('XXXXXXXXXXXXXXXX')) {
      return Platform.isAndroid ? _testAndroidAdUnitId : '';
    }
    return Platform.isAndroid ? _productionAndroidAdUnitId : '';
  }

  void loadAd({VoidCallback? onLoaded, Function(LoadAdError)? onFailed}) {
    if (kIsWeb || _isAdLoading || _rewardedAd != null) return;

    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('✅ Rewarded Ad loaded successfully.');
          _rewardedAd = ad;
          _isAdLoading = false;
          onLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Rewarded Ad failed to load: ${error.message}');
          _rewardedAd = null;
          _isAdLoading = false;
          onFailed?.call(error);
        },
      ),
    );
  }

  /// Displays rewarded ad and cleanly triggers reward AFTER ad dismissal
  void showAd({
    required BuildContext context,
    required VoidCallback onUserEarnedReward,
  }) {
    if (kIsWeb) return;

    if (_rewardedAd == null) {
      loadAd();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad is loading, please try again in a moment.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('📺 Rewarded Ad opened full screen.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('🚪 Rewarded Ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        loadAd(); // Preload next ad automatically

        // ⚡ Safely trigger reward AFTER ad screen closes
        if (userEarnedReward) {
          onUserEarnedReward();
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('❌ Rewarded Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('🎉 User earned reward: ${reward.amount} ${reward.type}');
        userEarnedReward = true;
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}