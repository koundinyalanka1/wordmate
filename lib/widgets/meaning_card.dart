import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../theme/app_theme.dart';

class MeaningCard extends StatelessWidget {
  final Meaning meaning;
  final int index;
  final Function(String) onWordTap;

  const MeaningCard({
    super.key,
    required this.meaning,
    required this.index,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of speech header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meaning.partOfSpeech.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.background,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Definitions
          ...meaning.definitions.asMap().entries.map((entry) {
            final definition = entry.value;
            final defIndex = entry.key;

            return Padding(
              padding: EdgeInsets.only(
                bottom: defIndex < meaning.definitions.length - 1 ? 20 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Definition number and text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${defIndex + 1}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          definition.definition,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),

                  // Example
                  if (definition.example != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.only(left: 36),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.accent.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 16,
                            color: AppTheme.accent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"${definition.example}"',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Definition synonyms
                  if (definition.synonyms.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: _buildWordChips(
                        context,
                        'Similar',
                        definition.synonyms,
                        AppTheme.accent.withValues(alpha: 0.15),
                        AppTheme.accent,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Meaning-level synonyms
          if (meaning.synonyms.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: AppTheme.surfaceLight),
            const SizedBox(height: 16),
            _buildWordChips(
              context,
              'Synonyms',
              meaning.synonyms,
              AppTheme.accent.withValues(alpha: 0.15),
              AppTheme.accent,
            ),
          ],

          // Antonyms
          if (meaning.antonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildWordChips(
              context,
              'Antonyms',
              meaning.antonyms,
              AppTheme.error.withValues(alpha: 0.15),
              AppTheme.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordChips(
    BuildContext context,
    String label,
    List<String> words,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.take(8).map((word) {
            return GestureDetector(
              onTap: () => onWordTap(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

