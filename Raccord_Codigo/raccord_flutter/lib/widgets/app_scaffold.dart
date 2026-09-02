import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session.dart';
import '../core/theme_controller.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Los 8 módulos del proyecto (mockups 7, 7.1). Se usan tanto en las
/// tarjetas del dashboard como en el menú lateral de todas las pantallas
/// "dentro" de un proyecto.
// Orden pedido explícitamente por el usuario (2026-09-01): Guión,
// Escenas, Desglose, Plan de Rodaje, Personajes, Cast List, Galería,
// Crew List, Roles.
const appSideMenuItems = [
  ('Guión', Icons.description_outlined, '/guiones'),
  ('Escenas', Icons.movie_filter_outlined, '/escenas'),
  ('Desglose', Icons.checklist_outlined, '/desglose'),
  ('Plan de Rodaje', Icons.event_note_outlined, '/plan-rodaje'),
  ('Personajes', Icons.people_outline, '/personajes'),
  ('Cast List', Icons.theater_comedy_outlined, '/actores'),
  ('Galería', Icons.photo_library_outlined, '/galeria'),
  // Crew List va casi al final del menú porque es el listado de TODAS
  // las personas del proyecto (no solo elenco) — pedido explícito del
  // usuario para no confundirlo con "Cast List".
  ('Crew List', Icons.badge_outlined, '/crew-list'),
  ('Roles', Icons.admin_panel_settings_outlined, '/roles'),
];

// Nombre de la ruta que solo debe verse para roles que sí invitan gente
// al proyecto (Administrador/Director/Jefe de Departamento) — Onset y
// Usuario nunca invitan a nadie, así que ni siquiera deben ver la
// entrada "Roles" en el menú (antes salía para todos los roles, aunque
// el backend ya la rechazaba con 403 para estos dos).
const _kRestrictedMenuRoute = '/roles';

/// Reemplaza los `showModalBottomSheet` (hoja pegada al borde inferior)
/// por un diálogo centrado en pantalla — se ve mejor en Web/Desktop, que
/// es donde corre esta app la mayor parte del tiempo. El formulario que
/// se le pasa ya trae su propio scroll/padding interno (ver
/// `_SceneFormSheet`, `_ScriptFormSheet`, etc.), así que acá solo se
/// limita el ancho/alto máximo del diálogo.
Future<T?> showCenteredFormSheet<T>(BuildContext context, Widget child) {
  return showDialog<T>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: child,
      ),
    ),
  );
}

/// Panel con los 8 módulos, usado como contenido del `endDrawer` tipo
/// "hamburguesa" que ahora aparece en TODAS las pantallas dentro de un
/// proyecto (no solo el dashboard), para que la navegación entre módulos
/// esté siempre a un toque de distancia.
class AppSideMenu extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const AppSideMenu({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final session = context.watch<AuthSession>();
    // "Roles" (invitar/gestionar el equipo) solo tiene sentido para
    // quienes SÍ pueden invitar gente al proyecto (Administrador,
    // Director, Jefe de Departamento) — Onset y Usuario nunca invitan a
    // nadie, así que ni siquiera deben ver la entrada en el menú, aunque
    // el backend ya la rechazaba con 403 para ellos. Se evalúa contra el
    // rol EFECTIVO en el proyecto activo (session.can), no el rol global.
    final visibleItems = appSideMenuItems.where(
      (item) => item.$3 != _kRestrictedMenuRoute || session.can('invite_users'),
    );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...visibleItems.map((item) => ListTile(
              leading: Icon(item.$2, size: 20),
              title: Text(item.$1),
              onTap: () => onSelect(item.$3),
            )),
        const Divider(),
        SwitchListTile(
          secondary: Icon(themeController.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 20),
          title: const Text('Modo oscuro'),
          subtitle: const Text('Por defecto siempre inicia oscuro', style: TextStyle(fontSize: 11)),
          value: themeController.isDark,
          onChanged: (_) => themeController.toggle(),
        ),
      ],
    );
  }
}

/// Antepone el nombre del proyecto activo al título de la pantalla
/// ("Nubes - Guiones" en vez de solo "Guiones") — pedido explícito del
/// usuario (2026-09-01), aplicado en TODAS las pantallas porque todas
/// pasan por este mismo AppScaffold. Si todavía no hay proyecto activo
/// (ej. la pantalla de "Escoger/Crear Proyecto") se deja el título tal
/// cual, sin anteponer nada.
///
/// Excepción explícita (mismo pedido, 2026-09-01): el Dashboard pasa el
/// nombre del proyecto COMO título (porque ahí no hay un nombre de
/// pantalla distinto que mostrar) — si se antepusiera igual, saldría
/// duplicado ("Nubes - Nubes"). Cuando `title` ya es exactamente el
/// nombre del proyecto, se deja tal cual en vez de repetirlo.
String _titleWithProject(AuthSession session, String title) {
  final nombre = session.projectName;
  if (!session.hasProject || nombre == null || nombre.isEmpty) return title;
  if (title == nombre) return title;
  return '$nombre - $title';
}

/// Scaffold estándar de las pantallas "dentro" de un proyecto: barra
/// superior con wordmark + botón volver opcional + menú de usuario
/// (Perfil / Salir) + menú lateral de módulos, como en los mockups 7,
/// 7.1 y 8.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  // Por defecto el botón "volver" hace un pop normal. Algunas pantallas
  // (como el dashboard del proyecto) llegan aquí con la pila de
  // navegación vacía porque se usó pushNamedAndRemoveUntil, así que
  // necesitan indicar explícitamente a dónde volver.
  final VoidCallback? onBack;
  // Si se pasa un drawer explícito, se usa ese. Si no, y `showModuleMenu`
  // es true (el default), se arma automáticamente el menú de los 8
  // módulos — así todas las pantallas dentro de un proyecto tienen la
  // hamburguesa sin tener que repetir el drawer en cada una.
  final Widget? endDrawer;
  final bool showModuleMenu;
  // Ícono de casa en la barra superior que lleva directo al Dashboard —
  // en todas las pantallas menos el Dashboard mismo (ahí no tiene
  // sentido, ya está en el dashboard).
  final bool showHome;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = false,
    this.actions,
    this.floatingActionButton,
    this.onBack,
    this.endDrawer,
    this.showModuleMenu = true,
    this.showHome = true,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    // Fuerza que TODO lo que esta pantalla recibe ya construido (body,
    // endDrawer personalizado, acciones, FAB) se tire y se reconstruya
    // desde cero al cambiar de modo claro/oscuro — pedido explícito del
    // usuario ("si o si todo debe quedar ajustado al nuevo modo"). El
    // problema: muchas pantallas pintan con `AppColors.bg/surface/...`
    // (getters planos, no un InheritedWidget) en vez de
    // `Theme.of(context)`. Cuando el usuario cambia el modo desde el
    // menú, `ThemeController.notifyListeners()` solo obliga a
    // reconstruirse a los widgets que lo escuchan directamente — y como
    // `body`/`actions`/etc. ya vienen armados por la pantalla que llama
    // a `AppScaffold` (son la MISMA instancia de widget de antes),
    // Flutter los da por "sin cambios" y nunca vuelve a ejecutar su
    // build(), dejándolos con los colores del modo anterior hasta que
    // algo más los reconstruya (navegar y volver, etc.). Envolverlos acá
    // en una Key distinta por modo obliga a Flutter a descartar ese
    // árbol entero y reconstruirlo, sin tocar la pila de navegación.
    final themeMode = context.watch<ThemeController>().mode;
    final themeKey = ValueKey(themeMode);

    // En móvil/tablet vertical, el wordmark ("Raccord") no se encoge por
    // sí solo (es una imagen de ancho fijo, no un texto) y el bloque de
    // `actions` con scroll horizontal reportaba su ancho de CONTENIDO
    // completo (no el disponible) al AppBar, lo que hacía que el
    // NavigationToolbar le diera todo ese espacio y el wordmark quedara
    // tapado/solapado por los íconos. La solución: 1) achicar el
    // wordmark en pantallas angostas, y 2) acotar explícitamente el
    // ancho máximo del bloque de acciones con un `ConstrainedBox`, para
    // que reporte ESE ancho (y no el de todo su contenido) y realmente
    // recorte/scrollee en vez de solaparse con el título.
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;
    final wordmarkFontSize = isNarrow ? 14.0 : 20.0;

    final effectiveEndDrawer = endDrawer ??
        (showModuleMenu
            ? Drawer(
                child: SafeArea(
                  child: AppSideMenu(onSelect: (route) {
                    Navigator.of(context).pop(); // cierra el drawer
                    Navigator.of(context).pushNamed(route);
                  }),
                ),
              )
            : null);

    return Scaffold(
      endDrawer: effectiveEndDrawer == null ? null : KeyedSubtree(key: themeKey, child: effectiveEndDrawer),
      appBar: AppBar(
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: showBack,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppWordmark(fontSize: wordmarkFontSize),
            if (title.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(width: 1, height: 18, color: AppColors.border),
              const SizedBox(width: 12),
              Flexible(
                child: Text(_titleWithProject(session, title), style: TextStyle(fontSize: isNarrow ? 14 : 16, overflow: TextOverflow.ellipsis)),
              ),
            ],
          ],
        ),
        // Todas las acciones (home, las que trae cada pantalla,
        // notificaciones, menú y avatar) se envuelven en un solo scroll
        // horizontal en vez de una Row plana: con varias pantallas
        // agregando 1-2 íconos propios (Roles, Escenas, Desglose...),
        // en móvil angosto (~360-400px) la suma de íconos ya no cabe y
        // una Row normal dentro de `actions` no protege contra overflow
        // (a diferencia del `title`, que sí tiene `Flexible`+ellipsis).
        // El scroll horizontal garantiza que nunca se corte ni se salga
        // de pantalla, a costa de requerir un swipe si sobran íconos.
        actions: [
          ConstrainedBox(
            // Sin este límite explícito, un SingleChildScrollView dentro
            // de `actions` reporta el ancho de TODO su contenido (no el
            // disponible) al AppBar — acotarlo fuerza a que realmente
            // recorte/scrollee en vez de solaparse con el wordmark.
            constraints: BoxConstraints(maxWidth: isNarrow ? screenWidth * 0.42 : double.infinity),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHome)
                    IconButton(
                      icon: const Icon(Icons.home_outlined),
                      tooltip: 'Ir al Dashboard',
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false),
                    ),
                if (actions != null) KeyedSubtree(key: themeKey, child: Row(mainAxisSize: MainAxisSize.min, children: actions!)),
                // Solo el ícono por ahora (decisión explícita del usuario):
                // todavía no hay sistema de notificaciones real (ni tabla en
                // BD, ni eventos que las disparen) — eso queda como una
                // siguiente fase, a definir qué eventos notificar. Por ahora
                // solo reserva el espacio visual, como en la referencia de
                // FilmScript, y avisa que la función viene después.
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notificaciones (próximamente)',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificaciones: disponible próximamente')),
                      );
                    },
                  ),
                ),
                if (effectiveEndDrawer != null)
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      tooltip: 'Menú',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: AppColors.azulProfundo,
                    radius: 16,
                    child: Text(
                      (session.user?.nombre.isNotEmpty ?? false) ? session.user!.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onSelected: (value) async {
                    if (value == 'perfil') {
                      Navigator.of(context).pushNamed('/perfil');
                    } else if (value == 'proyectos') {
                      await session.clearProject();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/proyectos', (r) => false);
                      }
                    } else if (value == 'salir') {
                      await session.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'perfil', child: Row(children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 10), Text('Perfil')])),
                    PopupMenuItem(value: 'proyectos', child: Row(children: [Icon(Icons.movie_creation_outlined, size: 18), SizedBox(width: 10), Text('Cambiar proyecto')])),
                    PopupMenuDivider(),
                    PopupMenuItem(value: 'salir', child: Row(children: [Icon(Icons.logout, size: 18, color: AppColors.error), SizedBox(width: 10), Text('Salir', style: TextStyle(color: AppColors.error))])),
                  ],
                ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: KeyedSubtree(key: themeKey, child: body)),
      floatingActionButton: floatingActionButton == null ? null : KeyedSubtree(key: themeKey, child: floatingActionButton!),
    );
  }
}

/// Tarjeta de módulo usada en el dashboard del proyecto (mockup 7).
class ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        // El ícono se calcula proporcional al ancho real de la tarjeta
        // (en vez de un radio fijo de 26), así se ve grande de verdad en
        // pantallas anchas y no queda diminuto dentro de la tarjeta.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final radius = (constraints.maxWidth * 0.22).clamp(28.0, 46.0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: radius,
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white, size: radius * 0.9),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: onTap, child: const Text('Ver más')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
