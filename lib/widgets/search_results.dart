import 'package:flutter/material.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import 'word_detail_card.dart';

class SearchResults extends StatelessWidget {
  final DictionaryProvider provider;
  final VoidCallback onClear;
  final Function(String)? onWordTap;

  const SearchResults({
    super.key,
    required this.provider,
    required this.onClear,
    this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Not found state
    if (provider.searchState == SearchState.notFound) {
      return _buildEmptyState(
        context,
        colors,
        icon: Icons.search_off_rounded,
        title: 'Word not found',
        subtitle: provider.errorMessage,
      );
    }

    // Error state
    if (provider.searchState == SearchState.error) {
      return _buildEmptyState(
        context,
        colors,
        icon: Icons.error_outline_rounded,
        title: 'Oops!',
        subtitle: provider.errorMessage,
        isError: true,
      );
    }

    // Success state - show results
    if (provider.currentEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Definition found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Full word details for each entry
          ...provider.currentEntries.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < provider.currentEntries.length - 1 ? 20 : 0,
              ),
              child: WordDetailCard(
                entry: entry.value,
                onWordTap: onWordTap,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isError
                    ? colors.error.withValues(alpha: 0.1)
                    : colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isError
                    ? colors.error.withValues(alpha: 0.7)
                    : colors.textMuted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go back'),
              style: TextButton.styleFrom(
                foregroundColor: colors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
