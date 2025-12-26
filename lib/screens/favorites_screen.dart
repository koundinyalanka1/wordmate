import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/word_list_tile.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                                color: AppTheme.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.bookmark_rounded,
                                color: AppTheme.accent,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Saved Words',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.favorites.isEmpty
                              ? 'Your saved words will appear here'
                              : '${provider.favorites.length} word${provider.favorites.length == 1 ? '' : 's'} saved',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty state
                if (provider.favorites.isEmpty)
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
                                color: AppTheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bookmark_border_rounded,
                                size: 48,
                                color: AppTheme.textMuted.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No saved words yet',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the bookmark icon when viewing\na word to save it here',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Favorites list
                if (provider.favorites.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = provider.favorites[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WordListTile(
                              entry: entry,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        WordDetailScreen(entry: entry),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              onRemove: () {
                                provider.toggleFavorite(entry);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '"${entry.word}" removed from saved words',
                                      style: const TextStyle(color: AppTheme.textPrimary),
                                    ),
                                    backgroundColor: AppTheme.surface,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: AppTheme.accent,
                                      onPressed: () {
                                        provider.toggleFavorite(entry);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: provider.favorites.length,
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

