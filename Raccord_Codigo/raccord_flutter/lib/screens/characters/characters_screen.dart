import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/bulk_import.dart';
import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bulk_upload_button.dart';
import '../../widgets/state_views.dart';

/// Mockup 14: Crear Personaje. Actor (ficha técnica completa) se
/// gestiona aparte por lo extenso del formulario (ActorSchema).
class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  late Future<List<CharacterModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<CharacterModel>> _load() {
    final session = context.read<AuthSession>();
    return CharacterService(session.api).all();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canManage = session.can('create_characters');

    return AppScaffold(
      title: 'Personajes',
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
              icon: const Icon(Icons.add),
              label: const Text('Crear Personaje'),
            )
          : null,
      body: FutureBuilder<List<CharacterModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar los personajes.', onRetry: _reload);
          final characters = snap.data ?? [];
          if (characters.isEmpty) {
            return const EmptyView(message: 'Todavía no hay personajes creados.', icon: Icons.theater_comedy_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: characters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = characters[i];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: canManage ? () => _openForm(context, existing: c) : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: AppColors.surfaceVariant, child: Text(c.codigoPersonaje)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('${c.edad} años', style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (c.idPersonaje != null)
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_outlined),
                            tooltip: 'Ficha técnica del actor',
                            onPressed: () => Navigator.of(context).pushNamed('/actor-form', arguments: c.idPersonaje),
                          ),
                        if (canManage && c.idPersonaje != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: 'Eliminar',
                            onPressed: () => _delete(c),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {CharacterModel? existing}) async {
    final saved = await showCenteredFormSheet<bool>(
      context,
      _CharacterFormSheet(existing: existing),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(CharacterModel c) async {
    final idPersonaje = c.idPersonaje;
    if (idPersonaje == null) return;

    final confirmed = await confirmDelete(
      context,
      message: '¿Eliminar el personaje "${c.nombre}"? Esta acción no se puede deshacer.',
    );
    if (!confirmed) return;

    final session = context.read<AuthSession>();
    try {
      await CharacterService(session.api).delete(idPersonaje);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personaje eliminado')));
      }
      _reload();
    } on ApiException catch (e) {
      // Ej. "CHARACTER_HAS_ACTORS" si todavía tiene actores asignados.
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // ==========================================
  // CARGA MASIVA
  // ==========================================
  // Columnas esperadas: codigo (o codigo_personaje), nombre, edad.
  // Las 3 son obligatorias (ver CharacterModel.toCreateJson).
  Future<List<BulkRowResult>> _bulkCreate(List<Map<String, String>> rows) async {
    final session = context.read<AuthSession>();
    final service = CharacterService(session.api);
    final results = <BulkRowResult>[];

    var fila = 1;
    for (final row in rows) {
      fila++;
      final codigo = _pick(row, ['codigo_personaje', 'codigo', 'código']);
      final nombre = _pick(row, ['nombre']);
      final edadTexto = _pick(row, ['edad']);
      final edad = edadTexto != null ? int.tryParse(edadTexto) : null;

      if (codigo == null || nombre == null || edad == null) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'Faltan columnas requeridas (codigo, nombre, edad)'));
        continue;
      }

      try {
        await service.create(CharacterModel(nombre: nombre, edad: edad, codigoPersonaje: codigo));
        results.add(BulkRowResult(fila: fila, ok: true, detalle: 'Creado correctamente'));
      } on ApiException catch (e) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: e.message));
      } catch (e) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: e.toString()));
      }
    }

    return results;
  }

  String? _pick(Map<String, String> row, List<String> posiblesLlaves) {
    for (final key in posiblesLlaves) {
      final value = row[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class _CharacterFormSheet extends StatefulWidget {
  final CharacterModel? existing;
  const _CharacterFormSheet({this.existing});

  @override
  State<_CharacterFormSheet> createState() => _CharacterFormSheetState();
}

class _CharacterFormSheetState extends State<_CharacterFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _codigo = TextEditingController(text: widget.existing?.codigoPersonaje ?? '');
  late final _nombre = TextEditingController(text: widget.existing?.nombre ?? '');
  late final _edad = TextEditingController(text: widget.existing != null ? '${widget.existing!.edad}' : '');
  bool _loading = false;

  bool get _isEditing => widget.existing != null;

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
            Text(_isEditing ? 'Editar Personaje' : 'Crear Personaje', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            AppTextField(label: 'Código del Personaje', hint: 'Ej: P001, P002', controller: _codigo, validator: _req),
            const SizedBox(height: 16),
            AppTextField(label: 'Nombre del Personaje', hint: 'Nombre del personaje', controller: _nombre, validator: _req),
            const SizedBox(height: 16),
            AppTextField(label: 'Edad', hint: 'Edad del personaje', controller: _edad, keyboardType: TextInputType.number, validator: _req),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
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
      final existing = widget.existing;
      if (existing != null && existing.idPersonaje != null) {
        await CharacterService(session.api).update(existing.idPersonaje!, {
          'nombre': _nombre.text.trim(),
          'edad': int.tryParse(_edad.text.trim()) ?? 0,
          'codigo_personaje': _codigo.text.trim(),
        });
      } else {
        await CharacterService(session.api).create(CharacterModel(
          nombre: _nombre.text.trim(),
          edad: int.tryParse(_edad.text.trim()) ?? 0,
          codigoPersonaje: _codigo.text.trim(),
        ));
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
