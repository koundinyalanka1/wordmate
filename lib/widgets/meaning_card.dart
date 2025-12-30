import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_entry.dart';
import '../providers/dictionary_provider.dart';
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
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
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
                    color: colors.background,
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
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${defIndex + 1}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
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
                      const SizedBox(width: 8),
                      // TTS button for definition
                      GestureDetector(
                        onTap: () => context.read<DictionaryProvider>().speakWord(definition.definition),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            color: colors.textMuted,
                            size: 16,
                          ),
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
                        color: colors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: colors.accent.withValues(alpha: 0.5),
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
                            color: colors.accent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"${definition.example}"',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // TTS button for example
                          GestureDetector(
                            onTap: () => context.read<DictionaryProvider>().speakWord(definition.example!),
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: colors.textMuted,
                              size: 16,
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
                        colors,
                        'Similar',
                        definition.synonyms,
                        colors.accent.withValues(alpha: 0.15),
                        colors.accent,
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
            Divider(color: colors.surfaceLight),
            const SizedBox(height: 16),
            _buildWordChips(
              context,
              colors,
              'Synonyms',
              meaning.synonyms,
              colors.accent.withValues(alpha: 0.15),
              colors.accent,
            ),
          ],

          // Antonyms
          if (meaning.antonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildWordChips(
              context,
              colors,
              'Antonyms',
              meaning.antonyms,
              colors.error.withValues(alpha: 0.15),
              colors.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordChips(
    BuildContext context,
    AppColors colors,
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
            color: colors.textMuted,
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
