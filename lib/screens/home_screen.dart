import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/word_of_day_card.dart';
import '../widgets/history_section.dart';
import '../widgets/search_results.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<DictionaryProvider>().searchWord(query);
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<DictionaryProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // App header
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
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppTheme.background,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'WordMate',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore the beauty of words',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onSearch: _onSearch,
                    onClear: _onClearSearch,
                  ),
                ),
              ),

              // Dynamic content based on search state
              Consumer<DictionaryProvider>(
                builder: (context, provider, _) {
                  if (provider.searchState == SearchState.loading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (provider.searchState == SearchState.success ||
                      provider.searchState == SearchState.notFound ||
                      provider.searchState == SearchState.error) {
                    return SliverToBoxAdapter(
                      child: SearchResults(
                        provider: provider,
                        onClear: _onClearSearch,
                      ),
                    );
                  }

                  // Default: show word of the day and history
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Word of the Day
                        if (provider.wordOfTheDay != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: WordOfDayCard(entry: provider.wordOfTheDay!),
                          ),

                        // Recent searches
                        if (provider.history.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: HistorySection(
                              history: provider.history,
                              onWordTap: (word) {
                                _searchController.text = word;
                                _onSearch(word);
                              },
                              onWordRemove: (word) {
                                provider.removeFromHistory(word);
                              },
                              onClearAll: () {
                                provider.clearHistory();
                              },
                            ),
                          ),

                        // Empty state
                        if (provider.history.isEmpty && provider.wordOfTheDay == null)
                          Padding(
                            padding: const EdgeInsets.all(48),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 64,
                                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Search for any word',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

