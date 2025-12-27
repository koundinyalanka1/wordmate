import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/word_detail_card.dart';

class WordOfDayScreen extends StatelessWidget {
  final Function(String)? onWordTap;

  const WordOfDayScreen({super.key, this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Consumer<DictionaryProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: colors.background,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Word of the Day',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expand your vocabulary daily',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // Word of the Day content
                if (provider.wordOfTheDay != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      child: WordDetailCard(
                        entry: provider.wordOfTheDay!,
                        showWordOfDayBadge: true,
                        onWordTap: onWordTap,
                      ),
                    ),
                  ),

                // Loading state
                if (provider.wordOfTheDay == null && !provider.isInitialized)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),

                // Error state
                if (provider.wordOfTheDay == null && provider.isInitialized)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cloud_off_rounded,
                                size: 48,
                                color: colors.textMuted.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Unable to load',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check your internet connection\nand try again',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

