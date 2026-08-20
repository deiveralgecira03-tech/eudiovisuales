import 'package:flutter/material.dart';

/// Paleta de marca Raccord, tomada de LandingScreen.css (frontend React
/// existente) para mantener consistencia visual entre plataformas.
class AppColors {
  AppColors._();

  static const azulProfundo = Color(0xFF0B4F8A);
  static const moradoTech = Color(0xFF7B5FCF);
  static const coral = Color(0xFFE67E5C);
  static const negro = Color(0xFF0A0A0A);
  static const grisOscuro = Color(0xFF3D3D3D);
  static const grisMedio = Color(0xFF6B6B6B);
  static const grisClaro = Color(0xFFE8E8E8);
  static const blanco = Color(0xFFFFFFFF);

  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);

  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF16171B);
  static const surfaceVariant = Color(0xFF1E2026);
  static const border = Color(0xFF2A2C33);

  static const gradientLogo = LinearGradient(
    colors: [azulProfundo, moradoTech, coral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.azulProfundo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.azulProfundo,
        secondary: AppColors.moradoTech,
        tertiary: AppColors.coral,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Montserrat',
        bodyColor: AppColors.blanco,
        displayColor: AppColors.blanco,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.blanco,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        hintStyle: const TextStyle(color: AppColors.grisMedio),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.azulProfundo, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulProfundo,
          foregroundColor: AppColors.blanco,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blanco,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.azulProfundo),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: const TextStyle(color: AppColors.blanco),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}