import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session.dart';
import '../core/theme_controller.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Los 8 módulos del proyecto (mockups 7, 7.1). Se usan tanto en las
/// tarjetas del dashboard como en el menú lateral de todas las pantallas
/// "dentro" de un proyecto.
const appSideMenuItems = [
  ('Guión', Icons.description_outlined, '/guiones'),
  ('Crear Escenas', Icons.movie_filter_outlined, '/escenas'),
  ('Personajes', Icons.people_outline, '/personajes'),
  ('Crew List', Icons.badge_outlined, '/crew-list'),
  ('Actores', Icons.theater_comedy_outlined, '/actores'),
  ('Plan de Rodaje', Icons.event_note_outlined, '/plan-rodaje'),
  ('Desglose', Icons.checklist_outlined, '/desglose'),
  ('Galería', Icons.photo_library_outlined, '/galeria'),
  ('Roles', Icons.admin_panel_settings_outlined, '/roles'),
];

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

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ...appSideMenuItems.map((item) => ListTile(
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
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

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
      endDrawer: effectiveEndDrawer,
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
            const AppWordmark(fontSize: 20),
            if (title.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(width: 1, height: 18, color: AppColors.border),
              const SizedBox(width: 12),
              Flexible(
                child: Text(title, style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis)),
              ),
            ],
          ],
        ),
        actions: [
          ...?actions,
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
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
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
