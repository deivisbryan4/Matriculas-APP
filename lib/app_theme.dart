import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Colores Institucional UNAJ
  static const Color navyBlue = Color(0xFF002366);
  static const Color mustardYellow = Color(0xFFFFDB58);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color whitePuro = Color(0xFFFFFFFF);

  // Semántica (Semáforo)
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color roseRed = Color(0xFFE32636);
  static const Color amberOrange = Color(0xFFFFBF00);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navyBlue,
        primary: navyBlue,
        secondary: mustardYellow,
        surface: whitePuro,
        error: roseRed,
      ),
      scaffoldBackgroundColor: lightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: navyBlue,
        foregroundColor: whitePuro,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          foregroundColor: whitePuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: whitePuro,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: navyBlue, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }
}
