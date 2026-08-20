import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';

/// Scaffold estándar de las pantallas "dentro" de un proyecto: barra
/// superior con wordmark + botón volver opcional + menú de usuario
/// (Perfil / Salir), como en los mockups 7, 7.1 y 8.
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
  // Menú lateral que se abre desde la derecha (tipo hamburguesa), en vez
  // de un menú que empuja el contenido hacia abajo.
  final Widget? endDrawer;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = false,
    this.actions,
    this.floatingActionButton,
    this.onBack,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return Scaffold(
      endDrawer: endDrawer,
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
          if (endDrawer != null)
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
