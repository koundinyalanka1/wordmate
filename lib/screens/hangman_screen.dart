import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_settings_provider.dart';
import '../services/dictionary_service.dart';
import '../services/word_list_service.dart';
import '../theme/app_theme.dart';

class HangmanScreen extends StatefulWidget {
  final Function(String)? onLookupWord;

  const HangmanScreen({super.key, this.onLookupWord});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  final WordListService _wordListService = WordListService();
  final DictionaryService _dictionaryService = DictionaryService();
  String _targetWord = '';
  Set<String> _guessedLetters = {};
  Set<String> _revealedLetters = {}; // Letters revealed at start (25%)
  List<String> _keyboardLetters = []; // Jumbled keyboard
  int _wrongGuesses = 0;
  bool _gameOver = false;
  bool _hasWon = false;
  bool _isLoading = true;
  int _score = 0;
  int _gamesPlayed = 0;
  String? _clue; // Definition clue
  bool _showClue = false;
  HangmanDifficulty? _currentDifficulty; // Track current difficulty
  static const int _maxWrongGuesses = 6;
  static const String _scoreKey = 'hangman_score';
  static const String _gamesKey = 'hangman_games';

  @override
  void initState() {
    super.initState();
    _initGame();
  }


  Future<void> _initGame() async {
    setState(() => _isLoading = true);
    await _loadScore();
    await _wordListService.loadWords();
    await _startNewGame();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt(_scoreKey) ?? 0;
      _gamesPlayed = prefs.getInt(_gamesKey) ?? 0;
    });
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoreKey, _score);
    await prefs.setInt(_gamesKey, _gamesPlayed);
  }

  Future<void> _startNewGame() async {
    setState(() {
      _isLoading = true;
      _clue = null;
      _showClue = false;
    });

    // Get difficulty settings
    final difficulty = context.read<GameSettingsProvider>().difficulty;
    final minLength = difficulty.minLength;
    final maxLength = difficulty.maxLength;

    // Get a random word based on difficulty
    String word = '';
    String? clue;
    
    // Try to find a word with a valid definition
    for (int attempt = 0; attempt < 10; attempt++) {
      for (int i = 0; i < 30; i++) {
        final candidate = _wordListService.getRandomWord();
        if (candidate.length >= minLength && 
            candidate.length <= maxLength && 
            RegExp(r'^[a-zA-Z]+$').hasMatch(candidate)) {
          word = candidate.toLowerCase();
          break;
        }
      }
      
      // Fallback words based on difficulty
      if (word.isEmpty) {
        switch (difficulty) {
          case HangmanDifficulty.easy:
            word = 'word';
          case HangmanDifficulty.medium:
            word = 'flutter';
          case HangmanDifficulty.hard:
            word = 'developer';
        }
      }

      // Try to fetch definition
      try {
        final entries = await _dictionaryService.getDefinition(word);
        if (entries.isNotEmpty && entries.first.meanings.isNotEmpty) {
          final firstMeaning = entries.first.meanings.first;
          if (firstMeaning.definitions.isNotEmpty) {
            clue = firstMeaning.definitions.first.definition;
            break; // Found a word with a definition
          }
        }
      } catch (e) {
        // Word not found in dictionary, try another
        word = '';
        continue;
      }
    }

    // Fallback if no definition found
    if (word.isEmpty) {
      word = 'flutter';
      clue = 'A popular cross-platform framework for building mobile apps';
    }

    final targetWord = word.toUpperCase();
    
    // Get unique letters in the word
    final uniqueLetters = targetWord.split('').toSet().toList();
    
    // Reveal 25% of unique letters
    final numToReveal = (uniqueLetters.length * 0.25).ceil();
    final random = Random();
    uniqueLetters.shuffle(random);
    final revealed = uniqueLetters.take(numToReveal).toSet();
    
    // Generate keyboard: word letters + some random extra letters
    final keyboardSet = <String>{};
    keyboardSet.addAll(targetWord.split(''));
    
    // Add random extra letters to make it more challenging (total ~12-16 letters)
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final targetKeyboardSize = min(16, max(12, targetWord.length + 6));
    while (keyboardSet.length < targetKeyboardSize) {
      final randomLetter = allLetters[random.nextInt(26)];
      keyboardSet.add(randomLetter);
    }
    
    // Shuffle keyboard letters
    final keyboard = keyboardSet.toList()..shuffle(random);

    setState(() {
      _targetWord = targetWord;
      _guessedLetters = {};
      _revealedLetters = revealed;
      _keyboardLetters = keyboard;
      _wrongGuesses = 0;
      _gameOver = false;
      _hasWon = false;
      _isLoading = false;
      _clue = clue;
      _showClue = false;
    });
  }

  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter) || _revealedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);
      
      if (!_targetWord.contains(letter)) {
        _wrongGuesses++;
        if (_wrongGuesses >= _maxWrongGuesses) {
          _gameOver = true;
          _hasWon = false;
          _gamesPlayed++;
          _saveScore();
        }
      } else {
        // Check if won
        final allLettersGuessed = _targetWord
            .split('')
            .every((l) => _guessedLetters.contains(l) || _revealedLetters.contains(l));
        if (allLettersGuessed) {
          _gameOver = true;
          _hasWon = true;
          _score++;
          _gamesPlayed++;
          _saveScore();
        }
      }
    });
  }

  void _toggleClue() {
    setState(() {
      _showClue = !_showClue;
    });
  }

  void _lookupWord() {
    if (widget.onLookupWord != null) {
      widget.onLookupWord!(_targetWord.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    // Watch for difficulty changes
    final gameSettings = context.watch<GameSettingsProvider>();
    final newDifficulty = gameSettings.difficulty;
    
    // If difficulty changed and we're not already loading, start a new game
    if (_currentDifficulty != null && _currentDifficulty != newDifficulty && !_isLoading) {
      _currentDifficulty = newDifficulty;
      // Schedule new game after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startNewGame();
      });
    } else if (_currentDifficulty == null) {
      _currentDifficulty = newDifficulty;
    }

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Finding a word...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  // Header with score
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
                                  Icons.games_rounded,
                                  color: colors.accent,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Hangman',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              // Score badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.accent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      color: colors.accent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_score',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: colors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Consumer<GameSettingsProvider>(
                            builder: (context, gameSettings, _) {
                              return Row(
                                children: [
                                  // Difficulty badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          gameSettings.difficulty.icon,
                                          size: 14,
                                          color: colors.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          gameSettings.difficulty.displayName,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: colors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(color: colors.textMuted),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_gamesPlayed games played',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Game content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Hangman drawing
                          _buildHangmanDrawing(colors),
                          const SizedBox(height: 20),

                          // Clue section
                          if (_clue != null) _buildClueSection(colors),
                          const SizedBox(height: 20),

                          // Word display
                          _buildWordDisplay(colors),
                          const SizedBox(height: 16),

                          // Wrong guesses counter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _wrongGuesses > 3 
                                  ? colors.error.withValues(alpha: 0.1)
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Lives: ${_maxWrongGuesses - _wrongGuesses} / $_maxWrongGuesses',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _wrongGuesses > 3 
                                    ? colors.error 
                                    : colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Game over message or keyboard
                          if (_gameOver)
                            _buildGameOverMessage(colors)
                          else
                            _buildKeyboard(colors),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildClueSection(AppColors colors) {
    return GestureDetector(
      onTap: _toggleClue,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _showClue ? colors.accent.withValues(alpha: 0.5) : colors.surfaceLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _showClue ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: _showClue ? colors.accent : colors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'CLUE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _showClue ? colors.accent : colors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showClue ? Icons.visibility_off : Icons.visibility,
                  color: colors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _showClue ? 'Hide' : 'Tap to reveal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
            if (_showClue) ...[
              const SizedBox(height: 12),
              Text(
                _clue!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHangmanDrawing(AppColors colors) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceLight),
      ),
      child: CustomPaint(
        painter: HangmanPainter(
          wrongGuesses: _wrongGuesses,
          color: colors.textPrimary,
          accentColor: colors.accent,
        ),
      ),
    );
  }

  Widget _buildWordDisplay(AppColors colors) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: _targetWord.split('').map((letter) {
        final isRevealed = _revealedLetters.contains(letter);
        final isGuessed = _guessedLetters.contains(letter);
        final showLetter = isRevealed || isGuessed || _gameOver;

        Color bgColor;
        Color borderColor;
        Color textColor;

        if (isRevealed) {
          bgColor = colors.surfaceLight;
          borderColor = colors.textMuted;
          textColor = colors.textMuted;
        } else if (isGuessed) {
          bgColor = colors.accent.withValues(alpha: 0.2);
          borderColor = colors.accent;
          textColor = colors.accent;
        } else if (_gameOver && !isGuessed) {
          bgColor = colors.error.withValues(alpha: 0.2);
          borderColor = colors.error;
          textColor = colors.error;
        } else {
          bgColor = colors.surface;
          borderColor = colors.surfaceLight;
          textColor = colors.textPrimary;
        }

        return Container(
          width: 36,
          height: 46,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              showLetter ? letter : '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameOverMessage(AppColors colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hasWon 
                ? colors.success.withValues(alpha: 0.15)
                : colors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasWon ? colors.success : colors.error,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _hasWon ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
                size: 48,
                color: _hasWon ? colors.success : colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _hasWon ? 'Congratulations!' : 'Game Over!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _hasWon ? colors.success : colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasWon 
                    ? 'You guessed "$_targetWord"!'
                    : 'The word was: $_targetWord',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (_hasWon) ...[
                const SizedBox(height: 8),
                Text(
                  'Score: $_score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            // Look up word button
            OutlinedButton.icon(
              onPressed: _lookupWord,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Look up'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(color: colors.accent),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // New game button
            ElevatedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboard(AppColors colors) {
    // Dynamic grid keyboard from jumbled letters - round bubbly buttons
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: _keyboardLetters.map((letter) {
        final isGuessed = _guessedLetters.contains(letter);
        final isRevealed = _revealedLetters.contains(letter);
        final isCorrect = _targetWord.contains(letter);
        final isDisabled = isGuessed || isRevealed;
        
        Color bgColor;
        Color textColor;
        Color borderColor;
        List<BoxShadow>? shadows;
        
        if (isRevealed) {
          bgColor = colors.surfaceLight.withValues(alpha: 0.5);
          textColor = colors.textMuted;
          borderColor = colors.surfaceLight;
          shadows = null;
        } else if (isGuessed) {
          if (isCorrect) {
            bgColor = colors.success;
            textColor = Colors.white;
            borderColor = colors.success;
            shadows = [
              BoxShadow(
                color: colors.success.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ];
          } else {
            bgColor = colors.error.withValues(alpha: 0.3);
            textColor = colors.error;
            borderColor = colors.error.withValues(alpha: 0.5);
            shadows = null;
          }
        } else {
          bgColor = colors.surface;
          textColor = colors.textPrimary;
          borderColor = colors.surfaceLight;
          shadows = [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];
        }

        return GestureDetector(
          onTap: isDisabled ? null : () => _guessLetter(letter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: shadows,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongGuesses;
  final Color color;
  final Color accentColor;

  HangmanPainter({
    required this.wrongGuesses,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final baseY = size.height - 15;
    final topY = 15.0;

    // Always draw the gallows
    canvas.drawLine(
      Offset(centerX - 45, baseY),
      Offset(centerX + 45, baseY),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX - 20, baseY),
      Offset(centerX - 20, topY),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX - 20, topY),
      Offset(centerX + 15, topY),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX + 15, topY),
      Offset(centerX + 15, topY + 12),
      paint,
    );

    final bodyPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headCenter = Offset(centerX + 15, topY + 23);
    const headRadius = 11.0;

    if (wrongGuesses >= 1) {
      canvas.drawCircle(headCenter, headRadius, bodyPaint);
    }

    if (wrongGuesses >= 2) {
      canvas.drawLine(
        Offset(centerX + 15, topY + 34),
        Offset(centerX + 15, topY + 62),
        bodyPaint,
      );
    }

    if (wrongGuesses >= 3) {
      canvas.drawLine(
        Offset(centerX + 15, topY + 42),
        Offset(centerX, topY + 52),
        bodyPaint,
      );
    }

    if (wrongGuesses >= 4) {
      canvas.drawLine(
        Offset(centerX + 15, topY + 42),
        Offset(centerX + 30, topY + 52),
        bodyPaint,
      );
    }

    if (wrongGuesses >= 5) {
      canvas.drawLine(
        Offset(centerX + 15, topY + 62),
        Offset(centerX, topY + 78),
        bodyPaint,
      );
    }

    if (wrongGuesses >= 6) {
      canvas.drawLine(
        Offset(centerX + 15, topY + 62),
        Offset(centerX + 30, topY + 78),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}
