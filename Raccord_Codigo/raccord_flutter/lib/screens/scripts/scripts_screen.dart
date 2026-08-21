import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/api_exception.dart';
import '../../core/date_utils.dart';
import '../../core/session.dart';
import '../../models/script.dart';
import '../../services/script_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

/// Mockup 8: Guiones (lista + filtro + edición inline + subir/crear
/// versión) y mockup 8.1 (lector de guión — PDF real, guardado en la
/// base de datos y visualizado embebido en la app).
class ScriptsScreen extends StatefulWidget {
  const ScriptsScreen({super.key});

  @override
  State<ScriptsScreen> createState() => _ScriptsScreenState();
}

class _ScriptsScreenState extends State<ScriptsScreen> {
  late Future<List<Script>> _future;
  // null = "Todos los estados".
  String? _filtroEstado;
  // Id del guión cuya tarjeta de edición está abierta (solo una a la vez).
  int? _editingId;

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
    final canEdit = session.can('upload_scripts');

    return AppScaffold(
      title: 'Guiones',
      showBack: true,
      floatingActionButton: canEdit
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

          final filtered = _filtroEstado == null ? scripts : scripts.where((s) => s.estado == _filtroEstado).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.grisMedio),
                    const SizedBox(width: 8),
                    DropdownButton<String?>(
                      value: _filtroEstado,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.surfaceVariant,
                      hint: const Text('Todos los estados'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Todos los estados')),
                        ...kEstadosGuion.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => setState(() => _filtroEstado = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyView(message: 'No hay guiones con ese estado.', icon: Icons.filter_alt_off_outlined)
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final s = filtered[i];
                            final isEditing = canEdit && _editingId == s.idGuion;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ScriptTile(
                                  script: s,
                                  canEdit: canEdit,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ScriptDetailScreen(script: s)),
                                  ),
                                  onEditTap: () => setState(() => _editingId = isEditing ? null : s.idGuion),
                                ),
                                if (isEditing)
                                  _ScriptEditCard(
                                    script: s,
                                    onCancel: () => setState(() => _editingId = null),
                                    onSaved: () {
                                      setState(() => _editingId = null);
                                      _reload();
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final created = await showCenteredFormSheet<bool>(
      context,
      const _ScriptFormSheet(),
    );
    if (created == true) _reload();
  }
}

Color colorForEstadoGuion(String estado) {
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

/// Abre el selector de archivos limitado a PDF. Devuelve null si la
/// persona cancela. `withData: true` es necesario para que los bytes
/// vengan listos en `PlatformFile.bytes` — imprescindible en Flutter
/// Web, donde no hay una ruta de archivo real que se pueda leer luego.
Future<PlatformFile?> pickPdfFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  return result.files.single;
}

String formatBytes(int? bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _ScriptTile extends StatelessWidget {
  final Script script;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _ScriptTile({required this.script, required this.canEdit, required this.onTap, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              script.tienePdf ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
              color: script.tienePdf ? AppColors.coral : AppColors.grisMedio,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(script.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusPill(label: script.estado, color: colorForEstadoGuion(script.estado)),
                      const SizedBox(width: 8),
                      Text(
                        'Versión: ${script.numeroDeVersion}',
                        style: const TextStyle(color: AppColors.grisMedio, fontSize: 12),
                      ),
                      if (script.tienePdf) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· ${formatBytes(script.archivoTamano)}',
                          style: const TextStyle(color: AppColors.grisMedio, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Editar',
                onPressed: onEditTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de edición rápida (mockup: nombre / estado / versión, más el
/// PDF) que aparece justo debajo del guión seleccionado. Los campos de
/// texto usan PATCH /scripts/{id}; el PDF se sube aparte con
/// POST /scripts/{id}/archivo (multipart).
class _ScriptEditCard extends StatefulWidget {
  final Script script;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _ScriptEditCard({required this.script, required this.onCancel, required this.onSaved});

  @override
  State<_ScriptEditCard> createState() => _ScriptEditCardState();
}

class _ScriptEditCardState extends State<_ScriptEditCard> {
  late final _nombre = TextEditingController(text: widget.script.nombre);
  late final _version = TextEditingController(text: widget.script.numeroDeVersion);
  late String _estado = widget.script.estado;
  PlatformFile? _nuevoPdf;
  bool _loading = false;

  @override
  void dispose() {
    _nombre.dispose();
    _version.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(label: 'Nombre del Guión', controller: _nombre),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: AppTextField(label: 'Versión', controller: _version),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Archivo PDF', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading ? null : _pickPdf,
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(
              _nuevoPdf?.name ??
                  (widget.script.tienePdf ? 'Reemplazar "${widget.script.archivoNombre}"' : 'Seleccionar PDF'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : widget.onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check, size: 18),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf() async {
    final file = await pickPdfFile();
    if (file != null) setState(() => _nuevoPdf = file);
  }

  Future<void> _submit() async {
    final idGuion = widget.script.idGuion;
    if (idGuion == null) return;
    if (_nombre.text.trim().isEmpty || _version.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y versión son requeridos')),
      );
      return;
    }

    setState(() => _loading = true);
    final session = context.read<AuthSession>();
    final service = ScriptService(session.api);

    try {
      await service.update(idGuion, {
        'nombre': _nombre.text.trim(),
        'estado': _estado,
        'numero_de_version': _version.text.trim(),
      });

      final pdf = _nuevoPdf;
      if (pdf != null && pdf.bytes != null) {
        await service.uploadArchivo(idGuion, bytes: pdf.bytes!, filename: pdf.name);
      }

      widget.onSaved();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

/// Vista completa de un guión (mockup 8.1): metadatos + el PDF real
/// embebido con Syncfusion PDF Viewer. El PDF vive en la base de datos
/// (GET /scripts/{id}/archivo) — se descarga una vez a memoria y se
/// renderiza con SfPdfViewer.memory, sin escribir nada a disco.
class ScriptDetailScreen extends StatefulWidget {
  final Script script;
  const ScriptDetailScreen({super.key, required this.script});

  @override
  State<ScriptDetailScreen> createState() => _ScriptDetailScreenState();
}

class _ScriptDetailScreenState extends State<ScriptDetailScreen> {
  Future<List<int>>? _pdfBytes;
  String? _pdfViewerError;

  @override
  void initState() {
    super.initState();
    // IMPORTANTE: no se puede llamar setState() aquí — initState()
    // corre durante la fase de construcción del widget y Flutter no
    // permite invalidar el árbol en ese momento (en modo release esto
    // no lanza un error visible, simplemente deja la pantalla en
    // blanco, sin spinner ni contenido). Por eso el future se asigna
    // directo al campo, no a través de _loadPdf().
    //
    // Se intenta cargar siempre contra el servidor (sin fiarse de
    // `widget.script.tienePdf`, que puede venir de una lista ya
    // desactualizada) — si en verdad no hay archivo, el backend
    // responde 404 y se muestra el estado vacío correspondiente.
    final idGuion = widget.script.idGuion;
    if (idGuion != null) {
      final session = context.read<AuthSession>();
      _pdfBytes = ScriptService(session.api).archivoBytes(idGuion);
    }
  }

  /// Reintento manual (botón "Reintentar" del ErrorView) — aquí sí es
  /// válido usar setState porque se llama después del primer build,
  /// disparado por una interacción del usuario.
  void _loadPdf() {
    final session = context.read<AuthSession>();
    final idGuion = widget.script.idGuion;
    if (idGuion == null) return;
    setState(() {
      _pdfViewerError = null;
      _pdfBytes = ScriptService(session.api).archivoBytes(idGuion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final script = widget.script;

    return AppScaffold(
      title: script.nombre,
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                StatusPill(label: script.estado, color: colorForEstadoGuion(script.estado)),
                const SizedBox(width: 10),
                Text('Versión ${script.numeroDeVersion}', style: const TextStyle(color: AppColors.grisMedio)),
                if (script.descripcion != null && script.descripcion!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      script.descripcion!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.grisMedio, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _buildPdfArea(context)),
        ],
      ),
    );
  }

  Widget _buildPdfArea(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _pdfBytes,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _PdfLoadingView();
        }
        if (snap.hasError) {
          // El backend responde 404 cuando el guión todavía no tiene
          // PDF cargado — eso no es un error real, es el estado vacío.
          if (snap.error is ApiException && (snap.error as ApiException).statusCode == 404) {
            return const EmptyView(
              message: 'Este guión todavía no tiene un PDF cargado.\nUsa el lápiz en la lista para adjuntarlo.',
              icon: Icons.picture_as_pdf_outlined,
            );
          }
          final message = snap.error is ApiException ? (snap.error as ApiException).message : 'No se pudo cargar el PDF.';
          return ErrorView(message: message, onRetry: _loadPdf);
        }
        final bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return const EmptyView(
            message: 'Este guión todavía no tiene un PDF cargado.\nUsa el lápiz en la lista para adjuntarlo.',
            icon: Icons.picture_as_pdf_outlined,
          );
        }

        // Chequeo mínimo: todo PDF válido empieza con la firma "%PDF".
        // Si esto no se cumple, el archivo llegó corrupto (problema de
        // red/descarga) y no tiene sentido pasárselo al visor — así
        // evitamos que Syncfusion falle en silencio y quede en blanco.
        final looksLikePdf = bytes.length > 4 &&
            bytes[0] == 0x25 && // %
            bytes[1] == 0x50 && // P
            bytes[2] == 0x44 && // D
            bytes[3] == 0x46; // F
        if (!looksLikePdf) {
          return ErrorView(
            message: 'El archivo descargado no es un PDF válido (llegó corrupto). Intenta de nuevo.',
            onRetry: _loadPdf,
          );
        }

        if (_pdfViewerError != null) {
          return ErrorView(message: _pdfViewerError!, onRetry: _loadPdf);
        }

        return SfPdfViewer.memory(
          Uint8List.fromList(bytes),
          onDocumentLoadFailed: (details) {
            debugPrint('SfPdfViewer onDocumentLoadFailed: ${details.description}');
            // No se puede llamar setState() de forma síncrona dentro de
            // este callback si todavía estamos construyendo el frame,
            // así que se difiere al próximo microtask.
            Future.microtask(() {
              if (mounted) setState(() => _pdfViewerError = details.description);
            });
          },
        );
      },
    );
  }
}

/// Spinner + texto mientras se descarga el PDF del guión (puede tardar
/// unos segundos según el tamaño del archivo).
class _PdfLoadingView extends StatelessWidget {
  const _PdfLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.azulProfundo),
          SizedBox(height: 16),
          Text('Cargando guión…', style: TextStyle(color: AppColors.grisMedio)),
        ],
      ),
    );
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
  final _descripcion = TextEditingController();
  String _estado = kEstadosGuion.first;
  PlatformFile? _pdf;
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
            Text('Archivo PDF', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : _pickPdf,
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: Text(_pdf?.name ?? 'Seleccionar PDF', overflow: TextOverflow.ellipsis),
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

  Future<void> _pickPdf() async {
    final file = await pickPdfFile();
    if (file != null) setState(() => _pdf = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final session = context.read<AuthSession>();
    final service = ScriptService(session.api);

    try {
      final created = await service.create(Script(
        numeroDeVersion: _version.text.trim(),
        fechaDeEmision: DateTime.now(),
        estado: _estado,
        archivo: '',
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        idProject: session.projectId,
      ));

      final pdf = _pdf;
      if (pdf != null && pdf.bytes != null && created.idGuion != null) {
        await service.uploadArchivo(created.idGuion!, bytes: pdf.bytes!, filename: pdf.name);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
