import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import 'word_detail_card.dart';

class WordOfDayCard extends StatelessWidget {
  final WordEntry entry;
  final Function(String)? onWordTap;

  const WordOfDayCard({
    super.key,
    required this.entry,
    this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return WordDetailCard(
      entry: entry,
      showWordOfDayBadge: true,
      onWordTap: onWordTap,
    );
  }
}
