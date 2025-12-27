import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom theme extension for app-specific colors
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color accent;
  final Color accentLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color error;
  final Color success;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.accent,
    required this.accentLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.error,
    required this.success,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? accent,
    Color? accentLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? error,
    Color? success,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }

  // Dark theme colors
  static const dark = AppColors(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    surfaceLight: Color(0xFF252525),
    accent: Color(0xFFE8A838),
    accentLight: Color(0xFFF5C96A),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB0B0B0),
    textMuted: Color(0xFF707070),
    error: Color(0xFFE85555),
    success: Color(0xFF4CAF50),
  );

  // Light theme colors
  static const light = AppColors(
    background: Color(0xFFF8F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEDEBE8),
    accent: Color(0xFFD4872E),
    accentLight: Color(0xFFE8A838),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF5A5A5A),
    textMuted: Color(0xFF9A9A9A),
    error: Color(0xFFD43D3D),
    success: Color(0xFF3D9140),
  );
}

class AppTheme {
  // Accent gradient (works for both themes)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE8A838), Color(0xFFD4872E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    const colors = AppColors.dark;
    return _buildTheme(colors, Brightness.dark);
  }

  static ThemeData get lightTheme {
    const colors = AppColors.light;
    return _buildTheme(colors, Brightness.light);
  }

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.background,
        secondary: colors.accentLight,
        onSecondary: colors.background,
        error: colors.error,
        onError: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      textTheme: TextTheme(
        // Display - for hero text/word of the day
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        // Headlines - for section headers
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        // Titles - for card titles
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
        // Body text
        bodyLarge: GoogleFonts.sourceSans3(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.textMuted,
        ),
        // Labels
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.accent,
          letterSpacing: 1.5,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.surfaceLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        hintStyle: GoogleFonts.sourceSans3(
          color: colors.textMuted,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceLight,
        labelStyle: GoogleFonts.sourceSans3(
          color: colors.textSecondary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
