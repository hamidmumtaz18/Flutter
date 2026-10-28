// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFD4520E);
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B0C0);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: secondary,
        appBarTheme: const AppBarTheme(
          backgroundColor: secondary,
          foregroundColor: textLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: textMuted),
          hintStyle: const TextStyle(color: textMuted),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: textLight, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textLight),
          bodyLarge: TextStyle(color: textLight),
          bodyMedium: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: secondary,
          selectedItemColor: primary,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: Colors.white12,
        iconTheme: const IconThemeData(color: textMuted),
      );
}
