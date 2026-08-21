import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Logos reales de marca, tomados de Marketing/Logos y organizados en
/// assets/images/logos/ — el mismo patrón que usa `raccord_frontend`
/// (carpeta src/assets/).
///
/// - isotipoColor: círculo de marca — login, registro, recuperar
///   contraseña, 2FA.
/// - logoCcNegativo: logo completo (isotipo + wordmark, con las "c" en
///   color) — barra superior de TODAS las pantallas desde "Selección de
///   Proyecto" en adelante (AppScaffold y ProjectSelectionScreen).
/// - logoNegativo: logo completo, variante sin las "c" en color — usado
///   únicamente en la pantalla obligatoria "Registra Proyecto" que sigue
///   al registro de cuenta.
class AppLogos {
  AppLogos._();
  static const isotipoColor = 'assets/images/logos/isotipo_color.png';
  static const logoCcNegativo = 'assets/images/logos/logo_cc_negativo.png';
  static const logoNegativo = 'assets/images/logos/logo_negativo.png';
}

/// Isotipo circular de marca (mockups 1, 2, 5...). Si el archivo aún no
/// está copiado en assets/images/logos/, cae a un círculo con el
/// degradé de marca para no romper la pantalla.
class AppIsotipo extends StatelessWidget {
  final double size;
  const AppIsotipo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppLogos.isotipoColor,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradientLogo,
        ),
      ),
    );
  }
}

/// Wordmark "Raccord" que aparece en la barra superior. Por defecto usa
/// Logo_CC_Negativo (logo completo, "c" en color, para fondo oscuro) —
/// la pantalla obligatoria "Registra Proyecto" pasa
/// `asset: AppLogos.logoNegativo` explícitamente porque ahí va la otra
/// variante. Si el archivo no está disponible todavía, cae al texto
/// dibujado a mano para que la barra nunca quede vacía.
class AppWordmark extends StatelessWidget {
  final double fontSize;
  final Color baseColor;
  final String asset;
  const AppWordmark({
    super.key,
    this.fontSize = 28,
    this.baseColor = Colors.white,
    this.asset = AppLogos.logoCcNegativo,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: fontSize * 1.6,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackText(),
    );
  }

  Widget _fallbackText() {
    final style = TextStyle(
      fontFamily: 'Georgia',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: baseColor,
      letterSpacing: 0.5,
    );
    return RichText(
      text: TextSpan(style: style, children: [
        const TextSpan(text: 'Ra'),
        TextSpan(text: 'c', style: style.copyWith(color: AppColors.azulProfundo)),
        TextSpan(text: 'c', style: style.copyWith(color: AppColors.coral)),
        const TextSpan(text: 'ord'),
      ]),
    );
  }
}
