import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/scene.dart';
import '../../services/scene_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';
import 'scene_edit_screen.dart';
import 'scene_gallery_screen.dart';

/// Mockups 6/6.1: Escenas — lista con filtro por estado, orden y
/// paginación; el ojo abre las fotos de continuidad de la escena
/// (SceneGalleryScreen) y el lápiz abre la edición completa
/// (SceneEditScreen, que también incluye la carga de fotos).
class ScenesScreen extends StatefulWidget {
  const ScenesScreen({super.key});

  @override
  State<ScenesScreen> createState() => _ScenesScreenState();
}

enum _SortField { numero, diaDramatico, fecha, ciudad }

const _sortLabels = {
  _SortField.numero: 'Número de Escena',
  _SortField.diaDramatico: 'Día Dramático',
  _SortField.fecha: 'Fecha de Grabación',
  _SortField.ciudad: 'Ciudad',
};

const _pageSize = 10;

class _ScenesScreenState extends State<ScenesScreen> {
  late Future<List<Scene>> _future;
  String? _filtroEstado;
  _SortField _sortField = _SortField.numero;
  bool _sortAsc = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Scene>> _load() {
    final session = context.read<AuthSession>();
    return SceneService(session.api).all();
  }

  void _reload() => setState(() {
        _future = _load();
        _page = 0;
      });

  /// El número de escena puede venir como "1", "2A", etc. — se ordena
  /// numéricamente por la parte inicial de dígitos y, si empata (o no
  /// hay dígitos), por el texto completo.
  int _compareNumero(Scene a, Scene b) {
    final na = int.tryParse(RegExp(r'^\d+').stringMatch(a.numeroDeEscena) ?? '');
    final nb = int.tryParse(RegExp(r'^\d+').stringMatch(b.numeroDeEscena) ?? '');
    if (na != null && nb != null && na != nb) return na.compareTo(nb);
    return a.numeroDeEscena.compareTo(b.numeroDeEscena);
  }

  List<Scene> _filterSort(List<Scene> scenes) {
    var list = _filtroEstado == null ? scenes : scenes.where((s) => s.estado == _filtroEstado).toList();
    list = [...list];
    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case _SortField.numero:
          cmp = _compareNumero(a, b);
          break;
        case _SortField.diaDramatico:
          cmp = (a.diaDramatico ?? 0).compareTo(b.diaDramatico ?? 0);
          break;
        case _SortField.fecha:
          final fa = a.fechaDeGrabacion;
          final fb = b.fechaDeGrabacion;
          if (fa == null && fb == null) {
            cmp = 0;
          } else if (fa == null) {
            cmp = 1;
          } else if (fb == null) {
            cmp = -1;
          } else {
            cmp = fa.compareTo(fb);
          }
          break;
        case _SortField.ciudad:
          cmp = (a.ciudad ?? '').compareTo(b.ciudad ?? '');
          break;
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canEdit = session.can('create_scenes');

    return AppScaffold(
      title: 'Escenas',
      showBack: true,
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear Escena'),
            )
          : null,
      body: FutureBuilder<List<Scene>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar las escenas.', onRetry: _reload);
          final all = snap.data ?? [];
          if (all.isEmpty) {
            return const EmptyView(message: 'Todavía no hay escenas registradas.', icon: Icons.movie_filter_outlined);
          }

          final filtered = _filterSort(all);
          final totalPages = filtered.isEmpty ? 1 : ((filtered.length - 1) ~/ _pageSize) + 1;
          final page = _page.clamp(0, totalPages - 1);
          final start = page * _pageSize;
          final pageItems = filtered.skip(start).take(_pageSize).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.grisMedio),
                        const SizedBox(width: 8),
                        DropdownButton<String?>(
                          value: _filtroEstado,
                          underline: const SizedBox.shrink(),
                          dropdownColor: AppColors.surfaceVariant,
                          hint: const Text('Todos los estados'),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('Todos los estados')),
                            ...kEstadosEscena.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
                          ],
                          onChanged: (v) => setState(() {
                            _filtroEstado = v;
                            _page = 0;
                          }),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ordenar por: ', style: TextStyle(color: AppColors.grisMedio)),
                        DropdownButton<_SortField>(
                          value: _sortField,
                          underline: const SizedBox.shrink(),
                          dropdownColor: AppColors.surfaceVariant,
                          items: _SortField.values
                              .map((f) => DropdownMenuItem(value: f, child: Text(_sortLabels[f]!)))
                              .toList(),
                          onChanged: (v) => setState(() => _sortField = v ?? _sortField),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: _sortAsc ? 'Ascendente' : 'Descendente',
                          icon: Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 18),
                          onPressed: () => setState(() => _sortAsc = !_sortAsc),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: pageItems.isEmpty
                      ? const EmptyView(message: 'No hay escenas con ese estado.', icon: Icons.filter_alt_off_outlined)
                      : ListView.separated(
                          itemCount: pageItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _SceneRow(
                            scene: pageItems[i],
                            canEdit: canEdit,
                            onView: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => SceneGalleryScreen(scene: pageItems[i])),
                            ),
                            onEdit: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (_) => SceneEditScreen(scene: pageItems[i])),
                              );
                              if (changed == true) _reload();
                            },
                          ),
                        ),
                ),
                if (totalPages > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: page > 0 ? () => setState(() => _page = page - 1) : null,
                      ),
                      Text('Página ${page + 1} de $totalPages', style: const TextStyle(color: AppColors.grisMedio)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: page < totalPages - 1 ? () => setState(() => _page = page + 1) : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final created = await showCenteredFormSheet<bool>(
      context,
      const _SceneFormSheet(),
    );
    if (created == true) _reload();
  }
}

Color colorForEstadoEscena(String estado) {
  switch (estado) {
    case 'Finalizada':
      return AppColors.success;
    case 'En proceso':
      return AppColors.warning;
    default:
      return AppColors.error;
  }
}

class _SceneRow extends StatelessWidget {
  final Scene scene;
  final bool canEdit;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _SceneRow({required this.scene, required this.canEdit, required this.onView, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _Field('Escena', '#${scene.numeroDeEscena}', bold: true),
          ),
          Expanded(
            flex: 4,
            child: _Field('Encabezado', scene.encabezado),
          ),
          Expanded(
            flex: 3,
            child: _Field('Día Dramático', scene.diaDramatico != null ? 'Día ${scene.diaDramatico}' : '—'),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado', style: TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                const SizedBox(height: 6),
                StatusPill(label: scene.estado, color: colorForEstadoEscena(scene.estado)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            tooltip: 'Ver fotos de continuidad',
            onPressed: onView,
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Editar escena',
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Field(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }
}

class _SceneFormSheet extends StatefulWidget {
  const _SceneFormSheet();

  @override
  State<_SceneFormSheet> createState() => _SceneFormSheetState();
}

class _SceneFormSheetState extends State<_SceneFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numero = TextEditingController();
  final _encabezado = TextEditingController();
  final _descripcion = TextEditingController();
  final _ciudad = TextEditingController();
  String? _modoVista;
  String? _momentoDia;
  String _estado = kEstadosEscena.first;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nueva Escena', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Escena (Número)', hint: 'Ej: 1, 2A, 3B', controller: _numero, validator: _req)),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppTextField(label: 'Encabezado', hint: 'Título de la escena', controller: _encabezado, validator: _req),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Descripción', hint: 'Descripción de la escena', controller: _descripcion, maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Vista',
                    value: _modoVista,
                    hint: 'Seleccione vista',
                    items: kModosVista,
                    labelBuilder: (e) => e.toUpperCase(),
                    onChanged: (v) => setState(() => _modoVista = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Momento',
                    value: _momentoDia,
                    hint: 'Seleccione momento',
                    items: kMomentosDia,
                    labelBuilder: (e) => e,
                    onChanged: (v) => setState(() => _momentoDia = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppTextField(label: 'Ciudad', hint: 'Ciudad donde se grabará', controller: _ciudad)),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Estado',
                    value: _estado,
                    items: kEstadosEscena,
                    labelBuilder: (e) => e,
                    onChanged: (v) => setState(() => _estado = v ?? _estado),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final session = context.read<AuthSession>();

    try {
      await SceneService(session.api).create(Scene(
        numeroDeEscena: _numero.text.trim(),
        encabezado: _encabezado.text.trim(),
        descripcion: _descripcion.text.trim(),
        modoVista: _modoVista,
        momentoDia: _momentoDia,
        ciudad: _ciudad.text.trim(),
        estado: _estado,
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
