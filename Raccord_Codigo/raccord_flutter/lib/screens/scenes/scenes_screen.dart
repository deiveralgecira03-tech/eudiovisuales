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

/// Mockups 6.2/6.3 (Escenas): lista + crear escena.
class ScenesScreen extends StatefulWidget {
  const ScenesScreen({super.key});

  @override
  State<ScenesScreen> createState() => _ScenesScreenState();
}

class _ScenesScreenState extends State<ScenesScreen> {
  late Future<List<Scene>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Scene>> _load() {
    final session = context.read<AuthSession>();
    return SceneService(session.api).all();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Escenas',
      showBack: true,
      floatingActionButton: session.can('create_scenes')
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
          final scenes = snap.data ?? [];
          if (scenes.isEmpty) {
            return const EmptyView(message: 'Todavía no hay escenas registradas.', icon: Icons.movie_filter_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: scenes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = scenes[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: AppColors.surfaceVariant, child: Text('#${s.numeroDeEscena}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.encabezado, style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (s.modoYMomento.isNotEmpty)
                            Text(s.modoYMomento, style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                          if (s.diaDramatico != null)
                            Text('Día dramático ${s.diaDramatico}', style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _SceneFormSheet(),
      ),
    );
    if (created == true) _reload();
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
            AppTextField(label: 'Ciudad', hint: 'Ciudad donde se grabará', controller: _ciudad),
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
