import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/date_utils.dart';
import '../../core/session.dart';
import '../../models/script.dart';
import '../../services/script_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

/// Mockup 8: Guiones (lista + subir/crear versión).
class ScriptsScreen extends StatefulWidget {
  const ScriptsScreen({super.key});

  @override
  State<ScriptsScreen> createState() => _ScriptsScreenState();
}

class _ScriptsScreenState extends State<ScriptsScreen> {
  late Future<List<Script>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Script>> _load() {
    final session = context.read<AuthSession>();
    return ScriptService(session.api).byProject(session.projectId ?? '');
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Guiones',
      showBack: true,
      floatingActionButton: session.can('upload_scripts')
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Subir Guión'),
            )
          : null,
      body: FutureBuilder<List<Script>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar los guiones.', onRetry: _reload);
          final scripts = snap.data ?? [];
          if (scripts.isEmpty) {
            return const EmptyView(message: 'Este proyecto todavía no tiene guiones cargados.', icon: Icons.description_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: scripts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = scripts[i];
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            'Versión ${s.numeroDeVersion} · ${formatDateEs(s.fechaDeEmision)}',
                            style: const TextStyle(color: AppColors.grisMedio, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(label: s.estado, color: _colorForEstado(s.estado)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _colorForEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return AppColors.success;
      case 'Revisión':
        return AppColors.coral;
      case 'En Rodaje':
        return AppColors.azulProfundo;
      case 'Archivado':
        return AppColors.grisMedio;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _openForm(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _ScriptFormSheet(),
      ),
    );
    if (created == true) _reload();
  }
}

class _ScriptFormSheet extends StatefulWidget {
  const _ScriptFormSheet();

  @override
  State<_ScriptFormSheet> createState() => _ScriptFormSheetState();
}

class _ScriptFormSheetState extends State<_ScriptFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _version = TextEditingController();
  final _archivo = TextEditingController();
  final _descripcion = TextEditingController();
  String _estado = kEstadosGuion.first;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Subir Guión', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            AppTextField(label: 'Nombre del Guión', hint: 'Ej: El Último Amanecer - Versión Final', controller: _nombre, validator: _req),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Estado',
                    value: _estado,
                    items: kEstadosGuion,
                    labelBuilder: (e) => e,
                    onChanged: (v) => setState(() => _estado = v ?? _estado),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(label: 'Versión', hint: 'v1.0', controller: _version, validator: _req),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Archivo',
              hint: 'Nombre/URL del PDF (la carga directa se habilitará más adelante)',
              controller: _archivo,
              validator: _req,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Descripción', hint: 'Notas sobre esta versión', controller: _descripcion, maxLines: 3),
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
      await ScriptService(session.api).create(Script(
        numeroDeVersion: _version.text.trim(),
        fechaDeEmision: DateTime.now(),
        estado: _estado,
        archivo: _archivo.text.trim(),
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        idProject: session.projectId,
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
