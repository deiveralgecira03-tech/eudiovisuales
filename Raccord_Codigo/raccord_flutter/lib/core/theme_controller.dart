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
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    AppColors.isDark = isDark;
    notifyListeners();
  }
}
