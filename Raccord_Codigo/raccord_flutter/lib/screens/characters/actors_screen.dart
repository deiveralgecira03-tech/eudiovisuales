import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/bulk_import.dart';
import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bulk_upload_button.dart';
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
    final canManage = session.can('create_characters');

    return AppScaffold(
      title: 'Actores',
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
                    if (canManage && a.idActor != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Eliminar',
                        onPressed: () => _delete(a),
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

  Future<void> _delete(ActorModel a) async {
    final idActor = a.idActor;
    if (idActor == null) return;

    final confirmed = await confirmDelete(
      context,
      message: '¿Eliminar al actor "${a.nombreCompleto}"? Esta acción no se puede deshacer.',
    );
    if (!confirmed) return;

    final session = context.read<AuthSession>();
    try {
      await ActorService(session.api).delete(idActor);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actor eliminado')));
      }
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // ==========================================
  // CARGA MASIVA
  // ==========================================
  // Columnas esperadas (obligatorias): nombre, apellido, genero,
  // fecha_de_nacimiento (yyyy-mm-dd), talla_zapatos, ancho_espalda,
  // pecho, cintura, cadera, largo_manga, largo_pierna, color_cabello,
  // textura_cabello, tipo_piel, color_ojos, nacionalidad, doble_riesgo
  // (si/no, true/false, 1/0). Opcionales: talla_anillo, contorno_cabeza,
  // contorno_cuello, alergias, habilidades_especiales, restricciones,
  // comentarios_adicionales, id_personaje.
  Future<List<BulkRowResult>> _bulkCreate(List<Map<String, String>> rows) async {
    final session = context.read<AuthSession>();
    final service = ActorService(session.api);
    final results = <BulkRowResult>[];

    var fila = 1;
    for (final row in rows) {
      fila++;

      final nombre = _pick(row, ['nombre']);
      final apellido = _pick(row, ['apellido']);
      final generoTexto = _pick(row, ['genero', 'género']);
      final fechaTexto = _pick(row, ['fecha_de_nacimiento', 'fecha_nacimiento', 'fecha de nacimiento']);
      final tallaZapatos = _pick(row, ['talla_zapatos', 'talla de zapatos']);
      final anchoEspalda = _pick(row, ['ancho_espalda']);
      final pecho = _pick(row, ['pecho']);
      final cintura = _pick(row, ['cintura']);
      final cadera = _pick(row, ['cadera']);
      final largoManga = _pick(row, ['largo_manga']);
      final largoPierna = _pick(row, ['largo_pierna']);
      final colorCabello = _pick(row, ['color_cabello']);
      final texturaCabello = _pick(row, ['textura_cabello']);
      final tipoPiel = _pick(row, ['tipo_piel']);
      final colorOjos = _pick(row, ['color_ojos']);
      final nacionalidad = _pick(row, ['nacionalidad']);
      final dobleRiesgoTexto = _pick(row, ['doble_riesgo']);

      final faltantes = <String>[];
      if (nombre == null) faltantes.add('nombre');
      if (apellido == null) faltantes.add('apellido');
      if (generoTexto == null) faltantes.add('genero');
      if (fechaTexto == null) faltantes.add('fecha_de_nacimiento');
      if (tallaZapatos == null) faltantes.add('talla_zapatos');
      if (anchoEspalda == null) faltantes.add('ancho_espalda');
      if (pecho == null) faltantes.add('pecho');
      if (cintura == null) faltantes.add('cintura');
      if (cadera == null) faltantes.add('cadera');
      if (largoManga == null) faltantes.add('largo_manga');
      if (largoPierna == null) faltantes.add('largo_pierna');
      if (colorCabello == null) faltantes.add('color_cabello');
      if (texturaCabello == null) faltantes.add('textura_cabello');
      if (tipoPiel == null) faltantes.add('tipo_piel');
      if (colorOjos == null) faltantes.add('color_ojos');
      if (nacionalidad == null) faltantes.add('nacionalidad');

      if (faltantes.isNotEmpty) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'Faltan columnas: ${faltantes.join(', ')}'));
        continue;
      }

      final genero = _normalizarGenero(generoTexto!);
      if (genero == null) {
        results.add(BulkRowResult(
          fila: fila,
          ok: false,
          detalle: 'Género inválido "$generoTexto" (use: ${kGenerosActor.join(', ')})',
        ));
        continue;
      }

      final fechaNacimiento = DateTime.tryParse(fechaTexto!);
      if (fechaNacimiento == null) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'fecha_de_nacimiento inválida "$fechaTexto" (use yyyy-mm-dd)'));
        continue;
      }

      final dobleRiesgo = _parseBool(dobleRiesgoTexto);

      try {
        await service.create(ActorModel(
          nombre: nombre!,
          apellido: apellido!,
          genero: genero,
          fechaDeNacimiento: fechaNacimiento,
          tallaZapatos: tallaZapatos!,
          anchoEspalda: anchoEspalda!,
          pecho: pecho!,
          cintura: cintura!,
          cadera: cadera!,
          largoManga: largoManga!,
          largoPierna: largoPierna!,
          tallaAnillo: _pick(row, ['talla_anillo']),
          contornoCabeza: _pick(row, ['contorno_cabeza']),
          contornoCuello: _pick(row, ['contorno_cuello']),
          colorCabello: colorCabello!,
          texturaCabello: texturaCabello!,
          tipoPiel: tipoPiel!,
          colorOjos: colorOjos!,
          alergias: _pick(row, ['alergias']),
          habilidadesEspeciales: _pick(row, ['habilidades_especiales']),
          restricciones: _pick(row, ['restricciones']),
          comentariosAdicionales: _pick(row, ['comentarios_adicionales']),
          nacionalidad: nacionalidad!,
          dobleRiesgo: dobleRiesgo,
          idPersonaje: _pick(row, ['id_personaje']),
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

  String? _pick(Map<String, String> row, List<String> posiblesLlaves) {
    for (final key in posiblesLlaves) {
      final value = row[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  String? _normalizarGenero(String texto) {
    final t = texto.trim().toLowerCase();
    for (final g in kGenerosActor) {
      if (g == t) return g;
    }
    // Tolerar el error ortográfico esperado por el backend ("fenemino")
    // y variantes comunes de escritura del usuario.
    if (t == 'femenino' || t == 'fenemino') return 'fenemino';
    if (t == 'masculino') return 'masculino';
    if (t == 'otro') return 'otro';
    return null;
  }

  bool _parseBool(String? texto) {
    if (texto == null) return false;
    final t = texto.trim().toLowerCase();
    return t == 'si' || t == 'sí' || t == 'true' || t == '1' || t == 'yes';
  }
}
