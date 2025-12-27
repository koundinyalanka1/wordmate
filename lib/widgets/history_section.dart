import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistorySection extends StatelessWidget {
  final List<String> history;
  final Function(String) onWordTap;
  final Function(String) onWordRemove;
  final VoidCallback onClearAll;

  const HistorySection({
    super.key,
    required this.history,
    required this.onWordTap,
    required this.onWordRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'Clear all',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // History chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: history.take(15).map((word) {
            return GestureDetector(
              onTap: () => onWordTap(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.surfaceLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onWordRemove(word),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
