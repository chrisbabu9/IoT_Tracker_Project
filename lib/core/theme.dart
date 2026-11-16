import 'package:flutter/material.dart';

/// App theme colors and typography based on the TrackPoint design system.
class AppTheme {
  AppTheme._();

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0B1026);
  static const Color darkSidebar = Color(0xFF0E1533);
  static const Color darkNav = Color(0xFF0E1533);
  static const Color darkCard = Color(0xFF131C40);
  static const Color darkCardTop = Color(0xFF16204A);
  static const Color darkLine = Color(0xFF243063);
  static const Color darkText = Color(0xFFE8ECFF);
  static const Color darkMuted = Color(0xFF93A0CF);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF2F5FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightLine = Color(0xFFD5DCF3);
  static const Color lightText = Color(0xFF16204A);
  static const Color lightMuted = Color(0xFF5A6590);

  // Shared Accents
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color statusOk = Color(0xFF22C55E);
  static const Color statusWarn = Color(0xFFF59E0B);
  static const Color statusBad = Color(0xFFEF4444);
  static const Color statusMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [accentCyan, accentPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [accentBlue, accentPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient buzzerOnGradient = LinearGradient(
    colors: [accentCyan, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buzzerOffGradient = LinearGradient(
    colors: [statusBad, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [darkCardTop, darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Theme Data Builders
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentCyan,
        tertiary: accentPurple,
        surface: darkCard,
        error: statusBad,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkText,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkLine, width: 1),
        ),
      ),
      dividerColor: darkLine,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0C1331),
        labelStyle: const TextStyle(color: darkMuted, fontSize: 13),
        hintStyle: const TextStyle(color: darkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: statusBad),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: darkLine),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: darkText,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: accentBlue,
        secondary: accentCyan,
        tertiary: accentPurple,
        surface: lightCard,
        error: statusBad,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightText,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shadowColor: const Color(0x182A3A80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightLine, width: 1),
        ),
      ),
      dividerColor: lightLine,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F8FF),
        labelStyle: const TextStyle(color: lightMuted, fontSize: 13),
        hintStyle: const TextStyle(color: lightMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: statusBad),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: lightLine),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: lightText,
        ),
      ),
    );
  }
}
