import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
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

    return AppScaffold(
      title: 'Personajes',
      showBack: true,
      floatingActionButton: session.can('create_characters')
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
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
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
        child: const _CharacterFormSheet(),
      ),
    );
    if (created == true) _reload();
  }
}

class _CharacterFormSheet extends StatefulWidget {
  const _CharacterFormSheet();

  @override
  State<_CharacterFormSheet> createState() => _CharacterFormSheetState();
}

class _CharacterFormSheetState extends State<_CharacterFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
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
            const Text('Crear Personaje', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
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
      await CharacterService(session.api).create(CharacterModel(
        nombre: _nombre.text.trim(),
        edad: int.tryParse(_edad.text.trim()) ?? 0,
        codigoPersonaje: _codigo.text.trim(),
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
