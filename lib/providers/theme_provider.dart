import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CyberpunkAccent { cyan, magenta, green, yellow, purple }

class ThemeProvider extends ChangeNotifier {
  CyberpunkAccent _currentAccent = CyberpunkAccent.cyan;
  ThemeData _themeData;

  ThemeProvider() : _themeData = _buildCyberpunkTheme(CyberpunkAccent.cyan);

  ThemeData get themeData => _themeData;
  CyberpunkAccent get currentAccent => _currentAccent;

  Color get neonColor => _getNeonColor(_currentAccent);

  void cycleColorScheme() {
    final nextAccentIndex =
        (_currentAccent.index + 1) % CyberpunkAccent.values.length;
    _currentAccent = CyberpunkAccent.values[nextAccentIndex];
    _themeData = _buildCyberpunkTheme(_currentAccent);
    notifyListeners();
  }

  static Color _getNeonColor(CyberpunkAccent accent) {
    switch (accent) {
      case CyberpunkAccent.cyan:
        return const Color(0xFF00F0FF); // Bright cyan
      case CyberpunkAccent.magenta:
        return const Color(0xFFFF00FF); // Bright magenta
      case CyberpunkAccent.green:
        return const Color(0xFF00FF41); // Neon green
      case CyberpunkAccent.yellow:
        return const Color(0xFFFFFF00); // Electric yellow
      case CyberpunkAccent.purple:
        return const Color(0xFFBF00FF); // Electric purple
    }
  }

  static ThemeData _buildCyberpunkTheme(CyberpunkAccent accent) {
    final neonColor = _getNeonColor(accent);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Pure black
      colorScheme: ColorScheme.dark(
        primary: neonColor,
        secondary: neonColor.withOpacity(0.7),
        surface: const Color(0xFF1A1A1A),
        onSurface: const Color(0xFFE0E0E0),
        onPrimary: Colors.black,
        error: const Color(0xFFFF0040),
        tertiary: neonColor.withOpacity(0.3),
      ),
      textTheme: GoogleFonts.robotoMonoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: const Color(0xFFE0E0E0), displayColor: neonColor),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: neonColor.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: neonColor,
          elevation: 0,
          side: BorderSide(color: neonColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconTheme: IconThemeData(color: neonColor),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: neonColor,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: neonColor),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: neonColor.withOpacity(0.2),
        foregroundColor: neonColor,
        elevation: 0,
      ),
    );
  }
}
