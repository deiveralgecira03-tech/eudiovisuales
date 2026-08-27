import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Controla si la app se ve en modo oscuro o claro. Vive solo en
/// memoria (no se persiste a disco a propósito): cada vez que se abre
/// la app, el modo por defecto SIEMPRE es oscuro, tal como se pidió —
/// el cambio a claro dura únicamente la sesión/pestaña actual.
///
/// También mantiene sincronizado `AppColors.isDark`, que es lo que usan
/// las pantallas que pintan sus superficies con `AppColors.bg/surface/
/// surfaceVariant/border` directo (en vez de `Theme.of(context)`) para
/// saber qué variante de color mostrar.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeController() {
    AppColors.isDark = isDark;
  }

  void toggle() {
    // Se calcula el modo nuevo UNA sola vez y se usa para las dos
    // asignaciones — antes se leía el getter `isDark` de nuevo después
    // de reasignar `_mode`, lo cual daba el resultado correcto por
    // casualidad (el getter ya reflejaba el modo nuevo) pero era
    // confuso de leer y frágil ante cualquier cambio futuro.
    final nuevoModo = isDark ? ThemeMode.light : ThemeMode.dark;
    _mode = nuevoModo;
    AppColors.isDark = nuevoModo == ThemeMode.dark;
    notifyListeners();
  }
}
