import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../theme/app_theme.dart';

class WordListTile extends StatelessWidget {
  final WordEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const WordListTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final firstMeaning = entry.meanings.isNotEmpty ? entry.meanings.first : null;
    final firstDefinition = firstMeaning?.definitions.isNotEmpty == true
        ? firstMeaning!.definitions.first.definition
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.surfaceLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.word,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.accent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (firstMeaning != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            firstMeaning.partOfSpeech,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.displayPhonetic.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.displayPhonetic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                  if (firstDefinition != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      firstDefinition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action buttons
            if (onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.textMuted,
                  size: 22,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

