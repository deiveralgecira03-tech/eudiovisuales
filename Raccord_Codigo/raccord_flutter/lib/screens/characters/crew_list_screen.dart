import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

/// Mockup 13: Crew List — tabla Código / Nombre del personaje.
class CrewListScreen extends StatefulWidget {
  const CrewListScreen({super.key});

  @override
  State<CrewListScreen> createState() => _CrewListScreenState();
}

class _CrewListScreenState extends State<CrewListScreen> {
  late Future<List<CharacterModel>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthSession>();
    _future = CharacterService(session.api).all();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Crew List',
      showBack: true,
      body: FutureBuilder<List<CharacterModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return const ErrorView(message: 'No se pudo cargar el crew list.');

          final all = snap.data ?? [];
          final filtered = _query.isEmpty
              ? all
              : all.where((c) => c.nombre.toLowerCase().contains(_query.toLowerCase())).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar personaje por nombre...',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyView(message: 'Sin resultados.', icon: Icons.search_off)
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
                                leading: CircleAvatar(backgroundColor: AppColors.surfaceVariant, child: Text(c.codigoPersonaje, style: const TextStyle(fontSize: 11))),
                                title: Text(c.nombre),
                                subtitle: Text(c.codigoPersonaje, style: const TextStyle(color: AppColors.grisMedio)),
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
}
