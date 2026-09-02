import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/gallery_photo.dart';
import '../../services/gallery_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

/// Galería global del proyecto (mockups 9, 9.1, 9.2, 9.3, 12, 15):
/// todas las fotos de continuidad de todas las escenas, agrupadas por
/// escena — pedido explícito del usuario ("todas las fotos de todas
/// las escenas habidas y por haber"). Reutiliza GET /fotos (ver
/// GalleryService.all()) y el mismo visor a pantalla completa que ya
/// existe en Continuidad Visual (scene_edit_screen.dart).
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<GalleryPhoto>> _future;
  final _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
    _busqueda.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<List<GalleryPhoto>> _load() {
    final session = context.read<AuthSession>();
    return GalleryService(session.api).all(session.projectId ?? '');
  }

  void _reload() => setState(() => _future = _load());

  /// Extrae el número inicial de "numeroDeEscena" (ej. "3", "3A") para
  /// ordenar los grupos numéricamente en vez de alfabéticamente (donde
  /// "10" quedaría antes que "2").
  int _numeroOrden(String? numero) {
    final match = RegExp(r'\d+').firstMatch(numero ?? '');
    return match != null ? int.parse(match.group(0)!) : 1 << 30;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    // Separado de upload_photos a pedido explícito: Onset puede subir
    // fotos de continuidad, pero no eliminarlas.
    final canDelete = session.can('delete_photos');

    return AppScaffold(
      title: 'Galería',
      showBack: true,
      body: FutureBuilder<List<GalleryPhoto>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar las fotos.', onRetry: _reload);

          final todas = snap.data ?? [];
          if (todas.isEmpty) {
            return const EmptyView(
              message: 'Todavía no hay fotos de continuidad en ninguna escena.',
              icon: Icons.photo_library_outlined,
            );
          }

          final filtro = _busqueda.text.trim().toLowerCase();
          final fotos = filtro.isEmpty
              ? todas
              : todas.where((p) {
                  final campos = [
                    p.numeroDeEscenaOrigen ?? '',
                    p.encabezadoEscenaOrigen ?? '',
                    p.tipoFoto,
                    p.personajeCodigo ?? '',
                    p.descripcion ?? '',
                  ].join(' ').toLowerCase();
                  return campos.contains(filtro);
                }).toList();

          // Agrupar por escena, conservando el orden (más reciente
          // primero, según ya vienen ordenadas desde el backend).
          final porEscena = <String, List<GalleryPhoto>>{};
          for (final foto in fotos) {
            porEscena.putIfAbsent(foto.idEscena, () => []).add(foto);
          }
          final escenas = porEscena.keys.toList()
            ..sort((a, b) {
              final na = _numeroOrden(porEscena[a]!.first.numeroDeEscenaOrigen);
              final nb = _numeroOrden(porEscena[b]!.first.numeroDeEscenaOrigen);
              return na.compareTo(nb);
            });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Buscar',
                      hint: 'Por escena, encabezado, tipo de foto o personaje...',
                      controller: _busqueda,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${fotos.length} foto(s)', style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: fotos.isEmpty
                    ? const EmptyView(message: 'Ninguna foto coincide con la búsqueda.', icon: Icons.search_off)
                    : ListView.builder(
                        itemCount: escenas.length,
                        itemBuilder: (context, i) {
                          final idEscena = escenas[i];
                          final fotosEscena = porEscena[idEscena]!;
                          final primero = fotosEscena.first;
                          final etiqueta = (primero.numeroDeEscenaOrigen != null && primero.numeroDeEscenaOrigen!.isNotEmpty)
                              ? 'ESC ${primero.numeroDeEscenaOrigen} · ${primero.encabezadoEscenaOrigen ?? ''}'
                              : (primero.encabezadoEscenaOrigen ?? 'Escena');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        etiqueta,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                    ),
                                    Text('(${fotosEscena.length})', style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: fotosEscena.length,
                                  // `MaxCrossAxisExtent` en vez de un
                                  // `crossAxisCount` fijo: calcula cuántas
                                  // miniaturas caben según el ancho real
                                  // (menos columnas en móvil angosto, más
                                  // en tablet/desktop), en vez de siempre 4.
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 130,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemBuilder: (context, j) => _GalleryPhotoThumb(
                                    photo: fotosEscena[j],
                                    canDelete: canDelete,
                                    onDeleted: _reload,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Miniatura + visor, igual que _PhotoThumb en scene_edit_screen.dart
/// pero con la etiqueta de la escena visible en el visor (acá, a
/// diferencia de Continuidad Visual, la foto puede ser de cualquier
/// escena del proyecto).
class _GalleryPhotoThumb extends StatelessWidget {
  final GalleryPhoto photo;
  final bool canDelete;
  final VoidCallback onDeleted;

  const _GalleryPhotoThumb({required this.photo, required this.canDelete, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openViewer(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: AppColors.surfaceVariant,
                child: FutureBuilder<List<int>>(
                  future: GalleryService(context.read<AuthSession>().api).archivoBytes(photo.idFoto),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)));
                    }
                    if (snap.hasError || snap.data == null) {
                      return const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.grisMedio));
                    }
                    return Image.memory(Uint8List.fromList(snap.data!), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
                  },
                ),
              ),
            ),
          ),
        ),
        if (canDelete)
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                tooltip: 'Eliminar foto',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: () => _delete(context),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmDelete(
      context,
      message: '¿Eliminar esta foto de continuidad? Esta acción no se puede deshacer.',
    );
    if (!confirmed) return;

    final session = context.read<AuthSession>();
    try {
      await GalleryService(session.api).delete(photo.idFoto);
      onDeleted();
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openViewer(BuildContext context) {
    final etiquetaEscena = (photo.numeroDeEscenaOrigen != null && photo.numeroDeEscenaOrigen!.isNotEmpty)
        ? 'ESC ${photo.numeroDeEscenaOrigen} · ${photo.encabezadoEscenaOrigen ?? ''}'
        : (photo.encabezadoEscenaOrigen ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FutureBuilder<List<int>>(
                future: GalleryService(context.read<AuthSession>().api).archivoBytes(photo.idFoto),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Image.memory(Uint8List.fromList(snap.data!), fit: BoxFit.contain);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (etiquetaEscena.isNotEmpty)
                          Text(etiquetaEscena, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(
                          '${photo.tipoFoto}${photo.personajeCodigo != null && photo.personajeCodigo!.isNotEmpty ? ' · ${photo.personajeCodigo}' : ''}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (photo.descripcion != null && photo.descripcion!.isNotEmpty)
                          Text(photo.descripcion!, style: const TextStyle(color: Colors.white70)),
                        if (photo.notasContinuidad != null && photo.notasContinuidad!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(photo.notasContinuidad!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  if (canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white70),
                      tooltip: 'Eliminar foto',
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _delete(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
