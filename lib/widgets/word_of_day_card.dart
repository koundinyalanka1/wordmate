import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_entry.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import '../screens/word_detail_screen.dart';

class WordOfDayCard extends StatelessWidget {
  final WordEntry entry;

  const WordOfDayCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final firstMeaning = entry.meanings.isNotEmpty ? entry.meanings.first : null;
    final firstDefinition = firstMeaning?.definitions.isNotEmpty == true
        ? firstMeaning!.definitions.first.definition
        : null;

    return GestureDetector(
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
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2015), Color(0xFF1A1510)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'WORD OF THE DAY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Audio button
                if (entry.audioUrl != null)
                  GestureDetector(
                    onTap: () => provider.playPronunciation(entry.audioUrl),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Word
            Text(
              entry.word,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),

            // Phonetic
            if (entry.displayPhonetic.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.displayPhonetic,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],

            // Part of speech
            if (firstMeaning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  firstMeaning.partOfSpeech,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],

            // Definition
            if (firstDefinition != null) ...[
              const SizedBox(height: 16),
              Text(
                firstDefinition,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap to explore',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

