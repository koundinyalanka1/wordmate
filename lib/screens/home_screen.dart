import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/history_section.dart';
import '../widgets/search_results.dart';
import '../widgets/image_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _lastSyncedWord;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync search bar with provider's current search word
    _syncSearchBar();
  }

  void _syncSearchBar() {
    final provider = context.read<DictionaryProvider>();
    final currentWord = provider.currentSearchWord;
    
    // Only update if the word changed and is different from what's in the controller
    if (currentWord != null && 
        currentWord != _lastSyncedWord && 
        currentWord != _searchController.text) {
      _searchController.text = currentWord;
      _lastSyncedWord = currentWord;
    } else if (currentWord == null && _lastSyncedWord != null) {
      _searchController.clear();
      _lastSyncedWord = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      _searchController.text = query;
      context.read<DictionaryProvider>().searchWord(query);
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<DictionaryProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    // Sync search bar when provider changes (e.g., from Hangman lookup)
    final provider = context.watch<DictionaryProvider>();
    if (provider.currentSearchWord != null && 
        provider.currentSearchWord != _searchController.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.currentSearchWord != _searchController.text) {
          _searchController.text = provider.currentSearchWord!;
        }
      });
    }

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
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: colors.background,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Word Mate',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: colors.textPrimary,
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

              // Image slider (shows when we have images or are loading them)
              Consumer<DictionaryProvider>(
                builder: (context, provider, _) {
                  final showImageSlider = provider.searchState == SearchState.success ||
                      provider.searchState == SearchState.loading ||
                      provider.isLoadingImages ||
                      provider.images.isNotEmpty;

                  if (!showImageSlider) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverToBoxAdapter(
                    child: ImageSlider(
                      images: provider.images,
                      isLoading: provider.isLoadingImages,
                      searchWord: provider.currentImageSearchWord,
                    ),
                  );
                },
              ),

              // Dynamic content based on search state
              Consumer<DictionaryProvider>(
                builder: (context, provider, _) {
                  if (provider.searchState == SearchState.loading) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.accent,
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
                        onWordTap: _onSearch,
                      ),
                    );
                  }

                  // Default: show history or empty state
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recent searches
                        if (provider.history.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                        if (provider.history.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(48),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 48,
                                      color: colors.textMuted.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Search for any word',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Type a word above to get its\ndefinition, pronunciation & more',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bottom padding
                        const SizedBox(height: 100),
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
