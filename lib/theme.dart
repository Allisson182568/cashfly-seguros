// lib/core/theme.dart
// Tema visual da Cashfy Seguros

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Cores primárias ──────────────────────────────────────
  static const Color primary       = Color(0xFF6C4CF1); // roxo
  static const Color primaryLight  = Color(0xFF8B6FF5);
  static const Color primaryDark   = Color(0xFF4F35C7);

  // ── Cores de cashback (verde) ────────────────────────────
  static const Color cashback      = Color(0xFF00D26A);
  static const Color cashbackLight = Color(0xFFB3F5D5);
  static const Color cashbackDark  = Color(0xFF00A352);

  // ── Superfícies ──────────────────────────────────────────
  static const Color background    = Color(0xFF0D0D1A);
  static const Color surface       = Color(0xFF16162A);
  static const Color surfaceLight  = Color(0xFF1E1E35);
  static const Color cardBorder    = Color(0xFF2A2A45);

  // ── Texto ────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EFFE);
  static const Color textSecondary = Color(0xFF9B9BBF);
  static const Color textHint      = Color(0xFF5A5A7A);

  // ── Status ───────────────────────────────────────────────
  static const Color error         = Color(0xFFFF4D6D);
  static const Color warning       = Color(0xFFFFB830);
  static const Color success       = Color(0xFF00D26A);

  // ── Gradientes ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C4CF1), Color(0xFF9B6BF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cashbackGradient = LinearGradient(
    colors: [Color(0xFF00D26A), Color(0xFF00A352)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E35), Color(0xFF16162A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── ThemeData ────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: cashback,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      textTheme: GoogleFonts.dmSansTextTheme(
        const TextTheme(
          displayLarge  : TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
          displayMedium : TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 26),
          displaySmall  : TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          headlineSmall : TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          titleLarge    : TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          bodyLarge     : TextStyle(color: textPrimary, fontSize: 15),
          bodyMedium    : TextStyle(color: textSecondary, fontSize: 14),
          bodySmall     : TextStyle(color: textHint, fontSize: 12),
          labelLarge    : TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder),
        ),
        elevation: 0,
      ),
    );
  }
}