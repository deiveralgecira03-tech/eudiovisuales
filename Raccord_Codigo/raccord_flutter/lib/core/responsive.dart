import 'package:flutter/material.dart';

/// Ancho por debajo del cual se considera "móvil" — mismo umbral que ya
/// usaba `AppScaffold` internamente (`isNarrow`) para achicar el wordmark
/// y las acciones del AppBar.
const double kMobileBreakpoint = 600;

/// true si la pantalla actual es de ancho "móvil" (< 600px). Se usa para
/// decidir qué funciones pesadas NO deben ofrecerse en móvil — por
/// ejemplo, la "vista dividida" (guion en PDF + contenido lado a lado)
/// de Escenas/Editar Escena/Desglose: en una pantalla angosta ese layout
/// queda inutilizable de todas formas, y cargar el visor de PDF
/// (pdfrx/PDFium, que además trae su propio worker WASM y warnings de
/// fuentes en consola) no tiene sentido si nunca se va a ver bien.
bool isMobileScreen(BuildContext context) => MediaQuery.of(context).size.width < kMobileBreakpoint;
