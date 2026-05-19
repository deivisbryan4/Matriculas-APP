import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Executive Dark UNAJ
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color navyBlue = Color(0xFF1B2B6B);
  static const Color mustardYellow = Color(0xFFF5A623);
  static const Color plomoBorde = Color(0xFF2D2D2D);
  static const Color whiteText = Color(0xFFF1F5F9);
  static const Color greyText = Color(0xFF94A3B8);

  // Alias para retrocompatibilidad
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color whitePuro = Color(0xFFFFFFFF);

  // Semántica
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color roseRed = Color(0xFFEF4444);
  static const Color amberOrange = Color(0xFFF59E0B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: navyBlue,
        secondary: mustardYellow,
        surface: surface,
        onSurface: whiteText,
        error: roseRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: whiteText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: plomoBorde),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: plomoBorde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: plomoBorde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navyBlue, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: mustardYellow,
        unselectedItemColor: greyText,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
