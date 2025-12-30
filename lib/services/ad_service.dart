import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  
  AdService._();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  int _gameCount = 0;
  int _nextAdGame = 0; // Which game number to show ad on

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  // Test Ad Unit IDs - Replace with your real IDs for production
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2596031675923197/4095152632'; // Android test banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
    }
    return '';
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2596031675923197/6717446540'; // Android test interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test interstitial
    }
    return '';
  }

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _setNextAdGame();
    loadBannerAd();
    loadInterstitialAd();
  }

  /// Set next game count for showing interstitial (every 3rd or 4th game randomly)
  void _setNextAdGame() {
    _nextAdGame = _gameCount + 3 + Random().nextInt(2); // 3 or 4
  }

  /// Load banner ad
  void loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          notifyListeners(); // Notify UI to rebuild
          if (kDebugMode) debugPrint('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          if (kDebugMode) debugPrint('Banner ad failed: ${error.message} (${error.code})');
          // Retry after delay - "No fill" is normal, just retry later
          Future.delayed(const Duration(seconds: 60), loadBannerAd);
        },
      ),
    )..load();
  }

  /// Load interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          if (kDebugMode) debugPrint('Interstitial ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdLoaded = false;
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          if (kDebugMode) debugPrint('Interstitial ad failed: $error');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
        },
      ),
    );
  }

  /// Show interstitial ad for reveal answer (always show if loaded)
  Future<void> showInterstitialForReveal() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  /// Called when a new game starts, may show interstitial
  Future<bool> onNewGame() async {
    _gameCount++;
    
    if (_gameCount >= _nextAdGame && _isInterstitialAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      _setNextAdGame(); // Set next target
      return true; // Ad was shown
    }
    return false; // No ad shown
  }

  /// Dispose ads
  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
