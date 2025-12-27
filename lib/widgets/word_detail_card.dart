import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_entry.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';
import 'meaning_card.dart';

class WordDetailCard extends StatelessWidget {
  final WordEntry entry;
  final bool showWordOfDayBadge;
  final Function(String)? onWordTap;

  const WordDetailCard({
    super.key,
    required this.entry,
    this.showWordOfDayBadge = false,
    this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final isFavorite = provider.isFavoriteSync(entry.word);

    return Container(
      decoration: BoxDecoration(
        gradient: showWordOfDayBadge
            ? const LinearGradient(
                colors: [Color(0xFF2A2015), Color(0xFF1A1510)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: showWordOfDayBadge ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: showWordOfDayBadge
              ? AppTheme.accent.withValues(alpha: 0.3)
              : AppTheme.surfaceLight,
          width: 1,
        ),
        boxShadow: showWordOfDayBadge
            ? [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word of the day badge & actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showWordOfDayBadge)
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
                      )
                    else
                      const SizedBox.shrink(),
                    
                    // Action buttons
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        // Bookmark button
                        GestureDetector(
                          onTap: () => provider.toggleFavorite(entry),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? AppTheme.accent.withValues(alpha: 0.2)
                                  : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isFavorite ? AppTheme.accent : AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Word
                Text(
                  entry.word,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.accent,
                  ),
                ),

                // Phonetic
                if (entry.displayPhonetic.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.displayPhonetic,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],

                // Origin
                if (entry.origin != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.history_edu_rounded,
                          color: AppTheme.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORIGIN',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.accent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.origin!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Meanings
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...entry.meanings.asMap().entries.map((meaningEntry) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: meaningEntry.key < entry.meanings.length - 1 ? 16 : 0,
                    ),
                    child: MeaningCard(
                      meaning: meaningEntry.value,
                      index: meaningEntry.key,
                      onWordTap: onWordTap ?? (_) {},
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

