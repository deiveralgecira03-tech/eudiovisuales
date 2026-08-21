import 'package:flutter/material.dart';

/// Controla si la app se ve en modo oscuro o claro. Vive solo en
/// memoria (no se persiste a disco a propósito): cada vez que se abre
/// la app, el modo por defecto SIEMPRE es oscuro, tal como se pidió —
/// el cambio a claro dura únicamente la sesión/pestaña actual.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
