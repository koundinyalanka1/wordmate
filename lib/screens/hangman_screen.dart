import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../services/word_list_service.dart';
import '../theme/app_theme.dart';

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({super.key});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  final WordListService _wordListService = WordListService();
  String _targetWord = '';
  Set<String> _guessedLetters = {};
  int _wrongGuesses = 0;
  bool _gameOver = false;
  bool _hasWon = false;
  bool _isLoading = true;
  static const int _maxWrongGuesses = 6;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    setState(() => _isLoading = true);
    await _wordListService.loadWords();
    _startNewGame();
  }

  void _startNewGame() {
    // Get a random word that's good for hangman (5-10 letters, no spaces/hyphens)
    String word = '';
    
    for (int i = 0; i < 50; i++) {
      final candidate = _wordListService.getRandomWord();
      if (candidate.length >= 4 && 
          candidate.length <= 10 && 
          !candidate.contains(' ') && 
          !candidate.contains('-') &&
          candidate.toLowerCase() == candidate &&
          RegExp(r'^[a-z]+$').hasMatch(candidate)) {
        word = candidate;
        break;
      }
    }
    
    if (word.isEmpty) {
      word = 'flutter'; // Fallback word
    }

    setState(() {
      _targetWord = word.toUpperCase();
      _guessedLetters = {};
      _wrongGuesses = 0;
      _gameOver = false;
      _hasWon = false;
      _isLoading = false;
    });
  }

  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);
      
      if (!_targetWord.contains(letter)) {
        _wrongGuesses++;
        if (_wrongGuesses >= _maxWrongGuesses) {
          _gameOver = true;
          _hasWon = false;
        }
      } else {
        // Check if won
        final allLettersGuessed = _targetWord
            .split('')
            .every((l) => _guessedLetters.contains(l));
        if (allLettersGuessed) {
          _gameOver = true;
          _hasWon = true;
        }
      }
    });
  }

  void _lookupWord() {
    context.read<DictionaryProvider>().searchWord(_targetWord.toLowerCase());
    // Navigate to search tab would require a callback, so we just search
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.accent),
              )
            : CustomScrollView(
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
                                  Icons.games_rounded,
                                  color: colors.accent,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Hangman',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Guess the word letter by letter',
                            style: Theme.of(context).textTheme.bodyMedium,
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
                          const SizedBox(height: 32),

                          // Word display
                          _buildWordDisplay(colors),
                          const SizedBox(height: 24),

                          // Wrong guesses counter
                          Text(
                            'Wrong guesses: $_wrongGuesses / $_maxWrongGuesses',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _wrongGuesses > 3 
                                  ? colors.error 
                                  : colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

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

  Widget _buildHangmanDrawing(AppColors colors) {
    return Container(
      height: 200,
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
      spacing: 8,
      runSpacing: 8,
      children: _targetWord.split('').map((letter) {
        final isGuessed = _guessedLetters.contains(letter);
        final showLetter = isGuessed || _gameOver;

        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: showLetter 
                ? (isGuessed ? colors.accent.withValues(alpha: 0.2) : colors.error.withValues(alpha: 0.2))
                : colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: showLetter 
                  ? (isGuessed ? colors.accent : colors.error)
                  : colors.surfaceLight,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              showLetter ? letter : '',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isGuessed ? colors.accent : colors.error,
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
                    ? 'You guessed the word!'
                    : 'The word was: $_targetWord',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Look up word button
            OutlinedButton.icon(
              onPressed: _lookupWord,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Look up word'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(color: colors.accent),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // New game button
            ElevatedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboard(AppColors colors) {
    const rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) {
              final isGuessed = _guessedLetters.contains(letter);
              final isCorrect = _targetWord.contains(letter);
              
              Color bgColor;
              Color textColor;
              
              if (isGuessed) {
                if (isCorrect) {
                  bgColor = colors.success.withValues(alpha: 0.2);
                  textColor = colors.success;
                } else {
                  bgColor = colors.error.withValues(alpha: 0.2);
                  textColor = colors.error;
                }
              } else {
                bgColor = colors.surface;
                textColor = colors.textPrimary;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: isGuessed ? null : () => _guessLetter(letter),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isGuessed 
                              ? (isCorrect ? colors.success : colors.error)
                              : colors.surfaceLight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final baseY = size.height - 30;
    final topY = 30.0;

    // Always draw the gallows
    // Base
    canvas.drawLine(
      Offset(centerX - 60, baseY),
      Offset(centerX + 60, baseY),
      paint,
    );
    
    // Pole
    canvas.drawLine(
      Offset(centerX - 30, baseY),
      Offset(centerX - 30, topY),
      paint,
    );
    
    // Top bar
    canvas.drawLine(
      Offset(centerX - 30, topY),
      Offset(centerX + 20, topY),
      paint,
    );
    
    // Rope
    canvas.drawLine(
      Offset(centerX + 20, topY),
      Offset(centerX + 20, topY + 20),
      paint,
    );

    // Draw body parts based on wrong guesses
    final bodyPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headCenter = Offset(centerX + 20, topY + 35);
    const headRadius = 15.0;

    // Head
    if (wrongGuesses >= 1) {
      canvas.drawCircle(headCenter, headRadius, bodyPaint);
    }

    // Body
    if (wrongGuesses >= 2) {
      canvas.drawLine(
        Offset(centerX + 20, topY + 50),
        Offset(centerX + 20, topY + 90),
        bodyPaint,
      );
    }

    // Left arm
    if (wrongGuesses >= 3) {
      canvas.drawLine(
        Offset(centerX + 20, topY + 60),
        Offset(centerX, topY + 75),
        bodyPaint,
      );
    }

    // Right arm
    if (wrongGuesses >= 4) {
      canvas.drawLine(
        Offset(centerX + 20, topY + 60),
        Offset(centerX + 40, topY + 75),
        bodyPaint,
      );
    }

    // Left leg
    if (wrongGuesses >= 5) {
      canvas.drawLine(
        Offset(centerX + 20, topY + 90),
        Offset(centerX, topY + 115),
        bodyPaint,
      );
    }

    // Right leg
    if (wrongGuesses >= 6) {
      canvas.drawLine(
        Offset(centerX + 20, topY + 90),
        Offset(centerX + 40, topY + 115),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}

