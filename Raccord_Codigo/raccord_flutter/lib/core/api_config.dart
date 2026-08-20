import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Dirección base del backend FastAPI (api_usuarios).
///
/// Por defecto apunta a http://127.0.0.1:8000 (como en el .env.example
/// del backend y en el frontend React actual). Para correr contra un
/// backend remoto o desde un emulador/dispositivo físico, sobreescribe
/// con:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
///
/// También se puede cambiar en caliente con [ApiConfig.override] (por
/// ejemplo desde una pantalla de configuración) para pruebas rápidas.
class ApiConfig {
  ApiConfig._();

  static const _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String? _override;

  static void override(String url) {
    _override = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl {
    if (_override != null && _override!.isNotEmpty) return _override!;
    if (_fromEnv.isNotEmpty) return _fromEnv;

    // Emulador Android: 10.0.2.2 apunta al localhost de la máquina host.
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      } catch (_) {
        // Platform no disponible (p.ej. tests) -> usar default de abajo.
      }
    }

    return 'http://127.0.0.1:8000';
  }
}
