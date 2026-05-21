import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F0E14) : const Color(0xFFF9F5F1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF9E00),
        brightness: brightness,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2230) : Colors.black87,
      ),
    );
  }
}
