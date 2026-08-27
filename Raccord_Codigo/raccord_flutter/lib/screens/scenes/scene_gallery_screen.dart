import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session.dart';
import '../../models/gallery_photo.dart';
import '../../models/scene.dart';
import '../../services/gallery_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

/// Solo lectura: fotos de continuidad de una escena, sin edición ni
/// carga (eso vive en SceneEditScreen). Es lo que abre el ícono de
/// ojo en la lista de Escenas.
class SceneGalleryScreen extends StatefulWidget {
  final Scene scene;
  const SceneGalleryScreen({super.key, required this.scene});

  @override
  State<SceneGalleryScreen> createState() => _SceneGalleryScreenState();
}

class _SceneGalleryScreenState extends State<SceneGalleryScreen> {
  Future<List<GalleryPhoto>>? _photos;

  @override
  void initState() {
    super.initState();
    final idEscena = widget.scene.idEscena;
    if (idEscena != null) {
      final session = context.read<AuthSession>();
      _photos = GalleryService(session.api).byScene(idEscena);
    }
  }

  void _reload() {
    final idEscena = widget.scene.idEscena;
    if (idEscena == null) return;
    final session = context.read<AuthSession>();
    setState(() => _photos = GalleryService(session.api).byScene(idEscena));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '${widget.scene.encabezado} · Fotos',
      showBack: true,
      body: FutureBuilder<List<GalleryPhoto>>(
        future: _photos,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudieron cargar las fotos.', onRetry: _reload);
          final photos = snap.data ?? [];
          if (photos.isEmpty) {
            return const EmptyView(
              message: 'Esta escena todavía no tiene fotos de continuidad.',
              icon: Icons.photo_library_outlined,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: photos.length,
            // `MaxCrossAxisExtent` calcula columnas según el ancho real en
            // vez de un `crossAxisCount` fijo — menos columnas en móvil,
            // más en tablet/desktop.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) => _GalleryTile(photo: photos[i]),
          );
        },
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryPhoto photo;
  const _GalleryTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _open(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: AppColors.surfaceVariant,
          child: FutureBuilder<List<int>>(
            future: GalleryService(context.read<AuthSession>().api).archivoBytes(photo.idFoto),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)));
              }
              if (snap.hasError || snap.data == null) {
                return const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.grisMedio));
              }
              return Image.memory(Uint8List.fromList(snap.data!), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
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
                    return const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator());
                  }
                  return Image.memory(Uint8List.fromList(snap.data!), fit: BoxFit.contain);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${photo.tipoFoto}${photo.personajeCodigo != null && photo.personajeCodigo!.isNotEmpty ? ' · ${photo.personajeCodigo}' : ''}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
          ],
        ),
      ),
    );
  }
}
