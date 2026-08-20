import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Isotipo circular con gradiente de marca (mockups 1, 2, 5...).
class AppIsotipo extends StatelessWidget {
  final double size;
  const AppIsotipo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/isotipo_color.png',
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

/// Wordmark "Raccord" con las dos "c" resaltadas en degradé, tal como
/// aparece en el navbar de los mockups. Se dibuja con texto (no hay un
/// archivo de la tipografía del wordmark en Marketing/Logos) para que
/// escale nítido en cualquier densidad de pantalla.
class AppWordmark extends StatelessWidget {
  final double fontSize;
  final Color baseColor;
  const AppWordmark({super.key, this.fontSize = 28, this.baseColor = Colors.white});

  @override
  Widget build(BuildContext context) {
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
