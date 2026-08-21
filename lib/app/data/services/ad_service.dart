import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends GetxService {
  static const String appId = 'ca-app-pub-1636463359318195~5938693747';
  static const String interstitialAdUnitId = 'ca-app-pub-1636463359318195/8372108363';

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  Future<AdService> init() async {
    await MobileAds.instance.initialize();
    

    _loadInterstitial();
    return this;
  }

  void _loadInterstitial() {
    if (_isAdLoading) return;
    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          debugPrint('AdMob: Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoading = false;
          _interstitialAd = null;
          debugPrint('AdMob: Interstitial Ad Failed to Load: ${error.message}');
          // Try to reload after some time if failed
          Future.delayed(const Duration(minutes: 1), () => _loadInterstitial());
        },
      ),
    );
  }

  Future<void> showInterstitial({required VoidCallback onComplete}) async {
    if (_interstitialAd == null) {
      debugPrint('AdMob: Interstitial Ad not ready');
      _loadInterstitial();
      onComplete(); // Proceed even if ad is not ready
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdMob: Ad Dismissed');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob: Ad Failed to Show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onComplete();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdMob: Ad Showed');
      },
    );

    await _interstitialAd!.show();
  }
}
