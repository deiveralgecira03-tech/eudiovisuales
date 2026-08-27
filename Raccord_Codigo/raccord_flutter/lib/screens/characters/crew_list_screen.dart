import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/bulk_import.dart';
import '../../core/session.dart';
import '../../models/catalog.dart';
import '../../models/crew_member.dart';
import '../../services/crew_member_service.dart';
import '../../services/department_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bulk_upload_button.dart';
import '../../widgets/state_views.dart';

/// Crew List: directorio de TODAS las personas que trabajan en el
/// proyecto (director, jefes de departamento, técnicos, etc.), tengan
/// o no cuenta de acceso a la plataforma — pedido explícito del
/// usuario, distinto de "Cast List" (que es solo el elenco/actores).
/// Nombre, cargo, departamento y celular para poder contactar a cada
/// persona; soporta creación individual y carga masiva (CSV/JSON),
/// igual que Personajes/Actores.
class CrewListScreen extends StatefulWidget {
  const CrewListScreen({super.key});

  @override
  State<CrewListScreen> createState() => _CrewListScreenState();
}

class _CrewListScreenState extends State<CrewListScreen> {
  late Future<List<CrewMember>> _future;
  List<Department> _departamentos = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadDepartamentos();
  }

  Future<List<CrewMember>> _load() {
    final session = context.read<AuthSession>();
    return CrewMemberService(session.api).all(session.projectId ?? '');
  }

  Future<void> _loadDepartamentos() async {
    final session = context.read<AuthSession>();
    final departamentos = await DepartmentService(session.api).all();
    if (mounted) setState(() => _departamentos = departamentos);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canManage = session.can('create_characters');

    return AppScaffold(
      title: 'Crew List',
      showBack: true,
      actions: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BulkUploadButton(onRows: _bulkCreate, onDone: _reload),
          ),
      ],
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: const Text('Agregar Persona'),
            )
          : null,
      body: FutureBuilder<List<CrewMember>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudo cargar el crew list.', onRetry: _reload);

          final all = snap.data ?? [];
          final filtered = _query.isEmpty
              ? all
              : all.where((c) {
                  final campos = '${c.nombre} ${c.cargo} ${c.departamentoNombre ?? ''} ${c.celular ?? ''}'.toLowerCase();
                  return campos.contains(_query.toLowerCase());
                }).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre, cargo, departamento o celular...',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyView(
                          message: all.isEmpty ? 'Todavía no hay personas registradas.' : 'Sin resultados.',
                          icon: all.isEmpty ? Icons.badge_outlined : Icons.search_off,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final c = filtered[i];
                              return ListTile(
                                onTap: canManage ? () => _openForm(context, existing: c) : null,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.surfaceVariant,
                                  child: Text(c.nombre.isNotEmpty ? c.nombre[0].toUpperCase() : '?'),
                                ),
                                title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  [
                                    c.cargo,
                                    if (c.departamentoNombre != null && c.departamentoNombre!.isNotEmpty) c.departamentoNombre!,
                                    if (c.celular != null && c.celular!.isNotEmpty) c.celular!,
                                  ].join(' · '),
                                  style: const TextStyle(color: AppColors.grisMedio),
                                ),
                                trailing: canManage && c.idCrew != null
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        tooltip: 'Eliminar',
                                        onPressed: () => _delete(c),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {CrewMember? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CrewMemberFormDialog(departamentos: _departamentos, existing: existing),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(CrewMember c) async {
    final idCrew = c.idCrew;
    if (idCrew == null) return;

    final confirmed = await confirmDelete(
      context,
      message: '¿Eliminar a "${c.nombre}" del crew list? Esta acción no se puede deshacer.',
    );
    if (!confirmed) return;

    final session = context.read<AuthSession>();
    try {
      await CrewMemberService(session.api).delete(idCrew);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Persona eliminada')));
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // ==========================================
  // CARGA MASIVA
  // ==========================================
  // Columnas esperadas (obligatorias): nombre, cargo. Opcionales:
  // departamento (nombre, se resuelve contra el catálogo del
  // proyecto), celular, correo, notas.
  Future<List<BulkRowResult>> _bulkCreate(List<Map<String, String>> rows) async {
    final session = context.read<AuthSession>();
    final service = CrewMemberService(session.api);
    final results = <BulkRowResult>[];

    var fila = 1;
    for (final row in rows) {
      fila++;

      final nombre = _pick(row, ['nombre']);
      final cargo = _pick(row, ['cargo']);
      final departamentoTexto = _pick(row, ['departamento', 'área', 'area']);

      final faltantes = <String>[];
      if (nombre == null) faltantes.add('nombre');
      if (cargo == null) faltantes.add('cargo');

      if (faltantes.isNotEmpty) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'Faltan columnas: ${faltantes.join(', ')}'));
        continue;
      }

      String? idDepartamento;
      if (departamentoTexto != null) {
        final match = _findDepartamento(departamentoTexto);
        if (match == null) {
          results.add(BulkRowResult(fila: fila, ok: false, detalle: 'Departamento "$departamentoTexto" no existe'));
          continue;
        }
        idDepartamento = match.idDepartamento;
      }

      try {
        await service.create(CrewMember(
          nombre: nombre!,
          cargo: cargo!,
          idDepartamento: idDepartamento,
          celular: _pick(row, ['celular', 'telefono', 'teléfono']),
          correo: _pick(row, ['correo', 'email', 'mail']),
          notas: _pick(row, ['notas']),
          idProject: session.projectId,
        ));
        results.add(BulkRowResult(fila: fila, ok: true, detalle: 'Creado correctamente'));
      } on ApiException catch (e) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: e.message));
      } catch (e) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: e.toString()));
      }
    }

    return results;
  }

  Department? _findDepartamento(String texto) {
    final t = texto.trim().toLowerCase();
    for (final d in _departamentos) {
      if (d.nombre.trim().toLowerCase() == t) return d;
    }
    return null;
  }

  String? _pick(Map<String, String> row, List<String> posiblesLlaves) {
    for (final key in posiblesLlaves) {
      final value = row[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class _CrewMemberFormDialog extends StatefulWidget {
  final List<Department> departamentos;
  final CrewMember? existing;
  const _CrewMemberFormDialog({required this.departamentos, this.existing});

  @override
  State<_CrewMemberFormDialog> createState() => _CrewMemberFormDialogState();
}

class _CrewMemberFormDialogState extends State<_CrewMemberFormDialog> {
  late final _nombre = TextEditingController(text: widget.existing?.nombre ?? '');
  late final _cargo = TextEditingController(text: widget.existing?.cargo ?? '');
  late final _celular = TextEditingController(text: widget.existing?.celular ?? '');
  late final _correo = TextEditingController(text: widget.existing?.correo ?? '');
  late final _notas = TextEditingController(text: widget.existing?.notas ?? '');
  String? _idDepartamento;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _idDepartamento = widget.existing?.idDepartamento;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _cargo.dispose();
    _celular.dispose();
    _correo.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.existing != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editando ? 'Editar Persona' : 'Agregar Persona al Crew List',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Nombre completo', hint: 'Nombre y apellidos', controller: _nombre),
                const SizedBox(height: 14),
                AppTextField(label: 'Cargo', hint: 'Ej: Director, Sonidista, Gaffer...', controller: _cargo),
                const SizedBox(height: 14),
                AppDropdown<String?>(
                  label: 'Departamento (opcional)',
                  value: _idDepartamento,
                  hint: 'Selecciona un departamento',
                  items: [null, ...widget.departamentos.map((d) => d.idDepartamento)],
                  labelBuilder: (id) =>
                      id == null ? 'Sin departamento' : widget.departamentos.firstWhere((d) => d.idDepartamento == id).nombre,
                  onChanged: (v) => setState(() => _idDepartamento = v),
                ),
                const SizedBox(height: 14),
                AppTextField(label: 'Celular (opcional)', hint: 'Para poder contactarlo', controller: _celular, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                AppTextField(label: 'Correo (opcional)', controller: _correo, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                AppTextField(label: 'Notas (opcional)', controller: _notas, maxLines: 3),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 16),
                      label: Text(editando ? 'Guardar' : 'Agregar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nombre.text.trim().isEmpty || _cargo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y cargo son obligatorios')));
      return;
    }

    setState(() => _loading = true);
    final session = context.read<AuthSession>();
    final crew = CrewMember(
      idCrew: widget.existing?.idCrew,
      nombre: _nombre.text.trim(),
      cargo: _cargo.text.trim(),
      idDepartamento: _idDepartamento,
      celular: _celular.text.trim(),
      correo: _correo.text.trim(),
      notas: _notas.text.trim(),
      idProject: session.projectId,
    );

    try {
      if (widget.existing?.idCrew != null) {
        await CrewMemberService(session.api).update(widget.existing!.idCrew!, crew);
      } else {
        await CrewMemberService(session.api).create(crew);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
