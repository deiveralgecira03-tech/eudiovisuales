import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session.dart';
import '../../services/scene_service.dart';
import '../../services/script_service.dart';
import '../../services/shooting_day_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';

class _ModuleDef {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  const _ModuleDef(this.title, this.icon, this.color, this.route);
}

const _modules = [
  _ModuleDef('Guión', Icons.description_outlined, AppColors.azulProfundo, '/guiones'),
  _ModuleDef('Escenas', Icons.movie_filter_outlined, AppColors.moradoTech, '/escenas'),
  _ModuleDef('Plan de Rodaje', Icons.event_note_outlined, AppColors.coral, '/plan-rodaje'),
  _ModuleDef('Desglose', Icons.checklist_outlined, AppColors.grisMedio, '/desglose'),
];

const _sidebarItems = [
  ('Guión', Icons.description_outlined, '/guiones'),
  ('Escenas', Icons.movie_filter_outlined, '/escenas'),
  ('Personajes', Icons.people_outline, '/personajes'),
  ('Crew List', Icons.badge_outlined, '/crew-list'),
  ('Plan de Rodaje', Icons.event_note_outlined, '/plan-rodaje'),
  ('Desglose', Icons.checklist_outlined, '/desglose'),
  ('Galería', Icons.photo_library_outlined, '/galeria'),
  ('Roles', Icons.admin_panel_settings_outlined, '/roles'),
];

/// Shell del proyecto (mockups 7, 7.1, 7.2): header, menú lateral con
/// los 8 módulos y tarjetas de acceso rápido.
class ProjectDashboardScreen extends StatefulWidget {
  const ProjectDashboardScreen({super.key});

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: session.projectName ?? 'Proyecto',
      // Flecha para volver a "Gestión de Proyectos": la persona puede
      // trabajar en varios proyectos sin tener que salir de la plataforma
      // (cerrar sesión) para cambiar de uno a otro.
      showBack: true,
      onBack: () async {
        await session.clearProject();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/proyectos', (r) => false);
        }
      },
      // El menú de módulos ahora es un panel lateral tipo "hamburguesa"
      // que se abre desde el borde derecho (ver botón de menú en la
      // barra superior), en vez de una lista que empujaba las tarjetas
      // hacia abajo.
      endDrawer: Drawer(
        child: SafeArea(
          child: _SideMenu(onSelect: (route) {
            Navigator.of(context).pop(); // cierra el drawer
            Navigator.of(context).pushNamed(route);
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              // Ancho máximo para que, en pantallas anchas, las tarjetas
              // queden centradas en vez de estiradas hasta los bordes.
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.05,
                      children: _modules
                          .map((m) => ModuleCard(
                                icon: m.icon,
                                color: m.color,
                                title: m.title,
                                onTap: () => Navigator.of(context).pushNamed(m.route),
                              ))
                          .toList(),
                    );
                  }),
                  const SizedBox(height: 24),
                  const _ProjectSummary(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _SideMenu({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _sidebarItems
            .map((item) => ListTile(
                  leading: Icon(item.$2, size: 20),
                  title: Text(item.$1),
                  onTap: () => onSelect(item.$3),
                ))
            .toList(),
      ),
    );
  }
}

/// Resumen del proyecto con conteos reales (guiones, escenas, días de
/// rodaje). Reemplaza el panel de "Noticias" del mockup, que no tiene
/// respaldo en el backend todavía — mejor mostrar datos reales que
/// simular contenido.
class _ProjectSummary extends StatefulWidget {
  const _ProjectSummary();

  @override
  State<_ProjectSummary> createState() => _ProjectSummaryState();
}

class _ProjectSummaryState extends State<_ProjectSummary> {
  int? _guiones, _escenas, _rodajes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = context.read<AuthSession>();
    final projectId = session.projectId;
    if (projectId == null) return;

    try {
      final scripts = await ScriptService(session.api).byProject(projectId);
      int escenas = 0;
      for (final s in scripts) {
        if (s.idGuion != null) {
          escenas += (await SceneService(session.api).byScript(s.idGuion!)).length;
        }
      }
      final rodajes = await ShootingDayService(session.api).all();

      if (!mounted) return;
      setState(() {
        _guiones = scripts.length;
        _escenas = escenas;
        _rodajes = rodajes.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator());
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _stat('Guiones', _guiones),
          _stat('Escenas', _escenas),
          _stat('Días de rodaje', _rodajes),
        ],
      ),
    );
  }

  Widget _stat(String label, int? value) {
    return Expanded(
      child: Column(
        children: [
          Text('${value ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grisMedio, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
