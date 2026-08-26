import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/gallery_photo.dart';

/// Fotos de continuidad visual de una escena (mockup "Continuidad
/// Visual"). El binario vive en la base de datos — se sube con
/// multipart/form-data y se descarga aparte con [archivoBytes].
class GalleryService {
  final ApiClient api;
  GalleryService(this.api);

  Future<List<GalleryPhoto>> byScene(String idEscena) async {
    final data = await api.get('/scenes/$idEscena/fotos');
    return asListOfMap(data).map(GalleryPhoto.fromJson).toList();
  }

  Future<GalleryPhoto> upload(
    String idEscena, {
    required String tipoFoto,
    String? personajeCodigo,
    String? descripcion,
    String? notasContinuidad,
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    final data = await api.postFile(
      '/scenes/$idEscena/fotos',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
      fields: {
        'tipo_foto': tipoFoto,
        if (personajeCodigo != null && personajeCodigo.isNotEmpty) 'personaje_codigo': personajeCodigo,
        if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
        if (notasContinuidad != null && notasContinuidad.isNotEmpty) 'notas_continuidad': notasContinuidad,
      },
    );
    return GalleryPhoto.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<int>> archivoBytes(String idFoto) {
    return api.getBytes('/fotos/$idFoto/archivo');
  }

  Future<void> delete(String idFoto) async {
    await api.delete('/fotos/$idFoto');
  }
}
