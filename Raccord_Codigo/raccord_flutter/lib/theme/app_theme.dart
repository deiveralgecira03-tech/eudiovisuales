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

  // Superficies (mockups usan fondos oscuros con tarjetas ligeramente
  // más claras que el fondo).
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

  // ==========================================
  // TEMA CLARO
  // ==========================================
  // IMPORTANTE (dejar documentado para el próximo cambio): esta app
  // pinta la mayoría de sus superficies con `Container(color:
  // AppColors.surface/bg/...)` directo, en vez de leer
  // `Theme.of(context).colorScheme`. Ese theme claro sí cambia todo lo
  // que Flutter arma automáticamente a partir del Theme (AppBar,
  // botones, campos de texto, Card por defecto, SnackBar, texto base),
  // pero las superficies con color fijo (tarjetas de escenas/guiones,
  // fondos de pantalla, etc.) van a seguir viéndose oscuras hasta que
  // se reemplacen esos `AppColors.xxx` fijos por colores que salgan del
  // Theme activo. Es un cambio grande porque toca casi cada pantalla —
  // se puede hacer como una tanda de trabajo aparte si se quiere un
  // modo claro 100% consistente.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    const bgLight = Color(0xFFF5F5F7);
    const surfaceLight = Color(0xFFFFFFFF);
    const borderLight = Color(0xFFE1E1E6);

    return base.copyWith(
      scaffoldBackgroundColor: bgLight,
      primaryColor: AppColors.azulProfundo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.azulProfundo,
        secondary: AppColors.moradoTech,
        tertiary: AppColors.coral,
        surface: surfaceLight,
        error: AppColors.error,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Montserrat',
        bodyColor: AppColors.negro,
        displayColor: AppColors.negro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.negro,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgLight,
        hintStyle: const TextStyle(color: AppColors.grisMedio),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight),
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
          foregroundColor: AppColors.negro,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.azulProfundo),
      ),
      dividerTheme: const DividerThemeData(color: borderLight),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grisOscuro,
        contentTextStyle: const TextStyle(color: AppColors.blanco),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
