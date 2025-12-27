import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    
    // Update suggestions
    context.read<DictionaryProvider>().updateSuggestions(widget.controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (!_focusNode.hasFocus) {
      // Delay clearing suggestions to allow tap to register
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          context.read<DictionaryProvider>().clearSuggestions();
        }
      });
    }
  }

  void _selectSuggestion(String word) {
    widget.controller.text = word;
    _focusNode.unfocus();
    widget.onSearch(word);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final borderRadius = BorderRadius.circular(30);

    return Column(
      children: [
        // Search input using Material for proper clipping and elevation
        Material(
          color: colors.surface,
          borderRadius: borderRadius,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: _isFocused ? colors.accent : colors.surfaceLight,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                style: Theme.of(context).textTheme.bodyLarge,
                textInputAction: TextInputAction.search,
                cursorColor: colors.accent,
                onSubmitted: (value) {
                  context.read<DictionaryProvider>().clearSuggestions();
                  widget.onSearch(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search for a word...',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: Colors.transparent,
                  isDense: false,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 10),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused ? colors.accent : colors.textMuted,
                      size: 24,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                  ),
                  suffixIcon: _hasText
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: colors.textSecondary,
                                size: 16,
                              ),
                            ),
                            onPressed: () {
                              widget.onClear();
                              context.read<DictionaryProvider>().clearSuggestions();
                            },
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Autocomplete suggestions
        Consumer<DictionaryProvider>(
          builder: (context, provider, _) {
            if (provider.suggestions.isEmpty || !_isFocused) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.surfaceLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: provider.suggestions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;
                    final isLast = index == provider.suggestions.length - 1;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _selectSuggestion(word),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: colors.textMuted,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    word,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.north_west_rounded,
                                  size: 16,
                                  color: colors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: colors.surfaceLight,
                            indent: 52,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
