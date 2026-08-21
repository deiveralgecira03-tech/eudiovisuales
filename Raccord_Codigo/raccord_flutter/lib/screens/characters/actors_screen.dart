import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

/// Catálogo de Actores. Reutiliza `ActorFormScreen` (ficha técnica
/// completa, ya existente) para la creación; acá solo se listan los
/// campos más importantes del actor: nombre, género, nacionalidad y
/// si es doble de riesgo.
class ActorsScreen extends StatefulWidget {
  const ActorsScreen({super.key});

  @override
  State<ActorsScreen> createState() => _ActorsScreenState();
}

class _ActorsScreenState extends State<ActorsScreen> {
  late Future<List<ActorModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ActorModel>> _load() {
    final session = context.read<AuthSession>();
    return ActorService(session.api).all();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Actores',
      showBack: true,
      floatingActionButton: session.can('create_characters')
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/actor-form');
                _reload();
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Actor'),
            )
          : null,
      body: FutureBuilder<List<ActorModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar los actores.', onRetry: _reload);
          final actors = snap.data ?? [];
          if (actors.isEmpty) {
            return const EmptyView(message: 'Todavía no hay actores creados.', icon: Icons.theater_comedy_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: actors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = actors[i];
              final edad = _edad(a.fechaDeNacimiento);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surfaceVariant,
                      child: Text(a.nombre.isNotEmpty ? a.nombre[0].toUpperCase() : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${a.nombre} ${a.apellido}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            '${a.genero} · $edad años · ${a.nacionalidad}',
                            style: const TextStyle(color: AppColors.grisMedio, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (a.dobleRiesgo)
                      const Tooltip(
                        message: 'Doble de riesgo',
                        child: Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
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

  int _edad(DateTime nacimiento) {
    final now = DateTime.now();
    int edad = now.year - nacimiento.year;
    if (now.month < nacimiento.month || (now.month == nacimiento.month && now.day < nacimiento.day)) {
      edad--;
    }
    return edad;
  }
}
