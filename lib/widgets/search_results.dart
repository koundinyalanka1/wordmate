import 'package:flutter/material.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../screens/word_detail_screen.dart';
import 'word_list_tile.dart';

class SearchResults extends StatelessWidget {
  final DictionaryProvider provider;
  final VoidCallback onClear;

  const SearchResults({
    super.key,
    required this.provider,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // Not found state
    if (provider.searchState == SearchState.notFound) {
      return _buildEmptyState(
        context,
        icon: Icons.search_off_rounded,
        title: 'Word not found',
        subtitle: provider.errorMessage,
      );
    }

    // Error state
    if (provider.searchState == SearchState.error) {
      return _buildEmptyState(
        context,
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
              Text(
                'Results',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Results list
          ...provider.currentEntries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WordListTile(
                entry: entry,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => WordDetailScreen(entry: entry),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
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
                    ? AppTheme.error.withValues(alpha: 0.1)
                    : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isError
                    ? AppTheme.error.withValues(alpha: 0.7)
                    : AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go back'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

