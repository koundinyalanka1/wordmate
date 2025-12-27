import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/game_settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final themeProvider = context.watch<ThemeProvider>();
    final gameSettings = context.watch<GameSettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                            color: colors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: colors.accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your experience',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            // Settings content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance section
                    Text(
                      'APPEARANCE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theme toggle
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.surfaceLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _ThemeOption(
                            icon: Icons.light_mode_rounded,
                            title: 'Light Mode',
                            subtitle: 'Bright and clean interface',
                            isSelected: !themeProvider.isDarkMode,
                            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                            colors: colors,
                          ),
                          Divider(
                            height: 1,
                            color: colors.surfaceLight,
                            indent: 68,
                          ),
                          _ThemeOption(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: 'Easy on the eyes',
                            isSelected: themeProvider.isDarkMode,
                            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Game settings section
                    Text(
                      'HANGMAN DIFFICULTY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.surfaceLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _DifficultyOption(
                            difficulty: HangmanDifficulty.easy,
                            isSelected: gameSettings.difficulty == HangmanDifficulty.easy,
                            onTap: () => gameSettings.setDifficulty(HangmanDifficulty.easy),
                            colors: colors,
                          ),
                          Divider(
                            height: 1,
                            color: colors.surfaceLight,
                            indent: 68,
                          ),
                          _DifficultyOption(
                            difficulty: HangmanDifficulty.medium,
                            isSelected: gameSettings.difficulty == HangmanDifficulty.medium,
                            onTap: () => gameSettings.setDifficulty(HangmanDifficulty.medium),
                            colors: colors,
                          ),
                          Divider(
                            height: 1,
                            color: colors.surfaceLight,
                            indent: 68,
                          ),
                          _DifficultyOption(
                            difficulty: HangmanDifficulty.hard,
                            isSelected: gameSettings.difficulty == HangmanDifficulty.hard,
                            onTap: () => gameSettings.setDifficulty(HangmanDifficulty.hard),
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // About section
                    Text(
                      'ABOUT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.surfaceLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: colors.background,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Word Mate',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Version 1.0.0',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A beautiful dictionary app to explore words, save favorites, and expand your vocabulary.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(color: colors.surfaceLight, height: 1),
                          const SizedBox(height: 16),
                          
                          // Developer info
                          Row(
                            children: [
                              Icon(
                                Icons.code_rounded,
                                size: 16,
                                color: colors.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Developed by Your Mate Apps',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // API info
                          Row(
                            children: [
                              Icon(
                                Icons.api_rounded,
                                size: 16,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Powered by Free Dictionary API',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Version info
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Version 1.0.0 • Build 1',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accent.withValues(alpha: 0.15)
                    : colors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.accent : colors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.accent : colors.textMuted,
                  width: 2,
                ),
                color: isSelected ? colors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colors.background,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final HangmanDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _DifficultyOption({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accent.withValues(alpha: 0.15)
                    : colors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                difficulty.icon,
                color: isSelected ? colors.accent : colors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    difficulty.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.accent : colors.textMuted,
                  width: 2,
                ),
                color: isSelected ? colors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colors.background,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
