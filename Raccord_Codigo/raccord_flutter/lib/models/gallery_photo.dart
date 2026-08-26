import '../core/json_utils.dart';

/// Catálogo de tipos de foto de continuidad (mockup "Continuidad
/// Visual"). Debe coincidir con TIPOS_FOTO en
/// gallery_photo_schema.py del backend.
const kTiposFoto = ['Locación', 'Propuesta', 'Prueba', 'En Rodaje'];

/// Foto de continuidad asociada a una escena — el binario vive en la
/// base de datos (ver GalleryService.archivoBytes), acá solo van los
/// metadatos que trae GET /scenes/{id}/fotos.
class GalleryPhoto {
  final String idFoto;
  final String idEscena;
  final String tipoFoto;
  final String? personajeCodigo;
  final String? descripcion;
  final String? notasContinuidad;
  final String archivoNombre;
  final int archivoTamano;
  final DateTime? fechaSubida;

  GalleryPhoto({
    required this.idFoto,
    required this.idEscena,
    required this.tipoFoto,
    this.personajeCodigo,
    this.descripcion,
    this.notasContinuidad,
    required this.archivoNombre,
    required this.archivoTamano,
    this.fechaSubida,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    final fecha = asString(pick(json, ['fecha_subida']));
    return GalleryPhoto(
      idFoto: asString(pick(json, ['id_foto'])) ?? '',
      idEscena: asString(pick(json, ['id_escena'])) ?? '',
      tipoFoto: asString(pick(json, ['tipo_foto'])) ?? 'Propuesta',
      personajeCodigo: asString(pick(json, ['personaje_codigo'])),
      descripcion: asString(pick(json, ['descripcion'])),
      notasContinuidad: asString(pick(json, ['notas_continuidad'])),
      archivoNombre: asString(pick(json, ['archivo_nombre'])) ?? '',
      archivoTamano: asInt(pick(json, ['archivo_tamano'])) ?? 0,
      fechaSubida: fecha != null ? DateTime.tryParse(fecha) : null,
    );
  }
}
