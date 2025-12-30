import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/dictionary_provider.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'word_of_day_screen.dart';
import 'hangman_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AdService _adService = AdService.instance;

  @override
  void initState() {
    super.initState();
    // Listen to ad service changes
    _adService.addListener(_onAdServiceChanged);
  }

  @override
  void dispose() {
    _adService.removeListener(_onAdServiceChanged);
    super.dispose();
  }

  void _onAdServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _searchWord(String word) {
    // Switch to home tab and search
    setState(() => _currentIndex = 0);
    context.read<DictionaryProvider>().searchWord(word);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          WordOfDayScreen(onWordTap: _searchWord),
          HangmanScreen(onLookupWord: _searchWord),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final hasAd = _adService.isBannerAdLoaded && _adService.bannerAd != null;
          
          // Layout from top to bottom:
          // 1. Navigation bar (always)
          // 2. Banner ad (if loaded)
          // 3. System button padding (if buttons exist, i.e. bottomPadding > 0)
          
          return Container(
            color: colors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Navigation bar
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavBarItem(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          isSelected: _currentIndex == 0,
                          onTap: () => setState(() => _currentIndex = 0),
                          colors: colors,
                        ),
                        _NavBarItem(
                          icon: Icons.auto_awesome,
                          label: 'Today',
                          isSelected: _currentIndex == 1,
                          onTap: () => setState(() => _currentIndex = 1),
                          colors: colors,
                        ),
                        _NavBarItem(
                          icon: Icons.games_rounded,
                          label: 'Game',
                          isSelected: _currentIndex == 2,
                          onTap: () => setState(() => _currentIndex = 2),
                          colors: colors,
                        ),
                        _NavBarItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          isSelected: _currentIndex == 3,
                          onTap: () => setState(() => _currentIndex = 3),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ),
                // 2. Banner ad (centered, full width container)
                if (hasAd)
                  Container(
                    color: colors.surface,
                    width: double.infinity,
                    height: _adService.bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: _adService.bannerAd!.size.width.toDouble(),
                      height: _adService.bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _adService.bannerAd!),
                    ),
                  ),
                // 3. System button padding (only if device has button navigation)
                if (bottomPadding > 0)
                  SizedBox(height: bottomPadding),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colors.accent : colors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.accent : colors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
