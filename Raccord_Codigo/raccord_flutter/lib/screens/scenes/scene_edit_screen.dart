import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/gallery_photo.dart';
import '../../models/scene.dart';
import '../../services/gallery_service.dart';
import '../../services/scene_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';
import 'scenes_screen.dart' show colorForEstadoEscena;

/// Mockup 6.1: edición de escena + Continuidad Visual (subir y ver las
/// fotos de esa escena). Layout de dos paneles en pantallas anchas;
/// en angostas se apilan verticalmente.
class SceneEditScreen extends StatefulWidget {
  final Scene scene;
  const SceneEditScreen({super.key, required this.scene});

  @override
  State<SceneEditScreen> createState() => _SceneEditScreenState();
}

class _SceneEditScreenState extends State<SceneEditScreen> {
  late final _numero = TextEditingController(text: widget.scene.numeroDeEscena);
  late final _encabezado = TextEditingController(text: widget.scene.encabezado);
  late final _ciudad = TextEditingController(text: widget.scene.ciudad ?? '');
  late final _diaDramatico = TextEditingController(text: widget.scene.diaDramatico?.toString() ?? '');
  late final _fecha = TextEditingController(
    text: widget.scene.fechaDeGrabacion != null ? widget.scene.fechaDeGrabacion!.toIso8601String().split('T').first : '',
  );
  late String _estado = widget.scene.estado;
  bool _savingInfo = false;
  bool _changed = false;

  Future<List<Map<String, dynamic>>>? _cast;
  Future<List<GalleryPhoto>>? _photos;

  @override
  void initState() {
    super.initState();
    final idEscena = widget.scene.idEscena;
    if (idEscena != null) {
      final session = context.read<AuthSession>();
      _cast = SceneService(session.api).cast(idEscena);
      _photos = GalleryService(session.api).byScene(idEscena);
    }
  }

  @override
  void dispose() {
    _numero.dispose();
    _encabezado.dispose();
    _ciudad.dispose();
    _diaDramatico.dispose();
    _fecha.dispose();
    super.dispose();
  }

  void _reloadPhotos() {
    final idEscena = widget.scene.idEscena;
    if (idEscena == null) return;
    final session = context.read<AuthSession>();
    setState(() => _photos = GalleryService(session.api).byScene(idEscena));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canEditInfo = session.can('create_scenes');
    final canUpload = session.can('upload_photos');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: AppScaffold(
        title: 'Continuidad Visual',
        showBack: true,
        onBack: () => Navigator.of(context).pop(_changed),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 760;
            final infoPanel = _infoPanel(canEditInfo);
            final continuityPanel = _continuityPanel(canUpload);

            if (wide) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: infoPanel),
                    const SizedBox(width: 20),
                    Expanded(child: continuityPanel),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  infoPanel,
                  const SizedBox(height: 20),
                  continuityPanel,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _panelBox({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoPanel(bool canEdit) {
    return _panelBox(
      title: 'Información de la Escena',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: 'Escena', controller: _numero, enabled: canEdit),
          const SizedBox(height: 14),
          AppTextField(label: 'Encabezado', controller: _encabezado, enabled: canEdit),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Día Dramático',
            controller: _diaDramatico,
            enabled: canEdit,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          AppTextField(label: 'Ciudad', controller: _ciudad, enabled: canEdit),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Fecha de Grabación',
            controller: _fecha,
            enabled: canEdit,
            hint: 'AAAA-MM-DD',
            onTap: canEdit ? _pickDate : null,
            readOnly: canEdit,
          ),
          const SizedBox(height: 14),
          if (canEdit)
            AppDropdown<String>(
              label: 'Estado',
              value: _estado,
              items: kEstadosEscena,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _estado = v ?? _estado),
            )
          else ...[
            const Text('Estado', style: TextStyle(color: AppColors.grisMedio, fontSize: 12)),
            const SizedBox(height: 6),
            StatusPill(label: _estado, color: colorForEstadoEscena(_estado)),
          ],
          const SizedBox(height: 14),
          const Text('Personajes', style: TextStyle(color: AppColors.grisMedio, fontSize: 12)),
          const SizedBox(height: 6),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _cast,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
              }
              final cast = snap.data ?? [];
              if (cast.isEmpty) return const Text('— Sin personajes asignados —', style: TextStyle(color: AppColors.grisMedio));
              final label = cast.map((c) => '${c['codigo_personaje'] ?? ''} - ${c['nombre'] ?? ''}').join(', ');
              return Text(label);
            },
          ),
          if (canEdit) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingInfo ? null : _saveInfo,
                child: _savingInfo
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _continuityPanel(bool canUpload) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canUpload) _UploadPhotoCard(scene: widget.scene, onUploaded: _reloadPhotos),
        const SizedBox(height: 20),
        FutureBuilder<List<GalleryPhoto>>(
          future: _photos,
          builder: (context, snap) {
            final count = snap.data?.length;
            return Text(
              'Fotos de Continuidad${count != null ? ' ($count)' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            );
          },
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<GalleryPhoto>>(
          future: _photos,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
            if (snap.hasError) return ErrorView(message: 'No se pudieron cargar las fotos.', onRetry: _reloadPhotos);
            final photos = snap.data ?? [];
            if (photos.isEmpty) {
              return const EmptyView(message: 'Todavía no hay fotos de continuidad para esta escena.', icon: Icons.photo_library_outlined);
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, i) => _PhotoThumb(photo: photos[i]),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_fecha.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fecha.text = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _saveInfo() async {
    final idEscena = widget.scene.idEscena;
    if (idEscena == null) return;

    setState(() => _savingInfo = true);
    final session = context.read<AuthSession>();

    try {
      await SceneService(session.api).updatePartial(idEscena, {
        'numero_de_escena': _numero.text.trim(),
        'encabezado': _encabezado.text.trim(),
        'ciudad': _ciudad.text.trim(),
        'dia_dramatico': int.tryParse(_diaDramatico.text.trim()),
        'fecha_de_grabacion': _fecha.text.trim().isEmpty ? null : _fecha.text.trim(),
        'estado': _estado,
      });
      _changed = true;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escena actualizada')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _savingInfo = false);
    }
  }
}

class _UploadPhotoCard extends StatefulWidget {
  final Scene scene;
  final VoidCallback onUploaded;
  const _UploadPhotoCard({required this.scene, required this.onUploaded});

  @override
  State<_UploadPhotoCard> createState() => _UploadPhotoCardState();
}

class _UploadPhotoCardState extends State<_UploadPhotoCard> {
  String _tipoFoto = kTiposFoto.first;
  final _personaje = TextEditingController();
  final _descripcion = TextEditingController();
  final _notas = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _personaje.dispose();
    _descripcion.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subir Nueva Foto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          AppDropdown<String>(
            label: 'Tipo de Foto',
            value: _tipoFoto,
            items: kTiposFoto,
            labelBuilder: (e) => e,
            onChanged: (v) => setState(() => _tipoFoto = v ?? _tipoFoto),
          ),
          const SizedBox(height: 14),
          AppTextField(label: 'Personaje (Código)', hint: 'Ej: P001', controller: _personaje),
          const SizedBox(height: 14),
          AppTextField(label: 'Descripción', hint: 'Descripción de la foto', controller: _descripcion),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Notas de Continuidad',
            hint: 'Detalles relevantes para continuidad: vestuario, maquillaje, props, iluminación, etc.',
            controller: _notas,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _pickAndUpload,
              icon: _loading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(_loading ? 'Subiendo...' : 'Subir Foto(s)'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final idEscena = widget.scene.idEscena;
    if (idEscena == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _loading = true);
    final session = context.read<AuthSession>();
    final service = GalleryService(session.api);

    try {
      for (final f in result.files) {
        if (f.bytes == null) continue;
        await service.upload(
          idEscena,
          tipoFoto: _tipoFoto,
          personajeCodigo: _personaje.text.trim(),
          descripcion: _descripcion.text.trim(),
          notasContinuidad: _notas.text.trim(),
          bytes: f.bytes!,
          filename: f.name,
          contentType: _contentTypeFor(f.name),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto(s) cargada(s) correctamente')));
      }
      widget.onUploaded();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _contentTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

class _PhotoThumb extends StatelessWidget {
  final GalleryPhoto photo;
  const _PhotoThumb({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }

  void _openViewer(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${photo.tipoFoto}${photo.personajeCodigo != null && photo.personajeCodigo!.isNotEmpty ? ' · ${photo.personajeCodigo}' : ''}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
