import '../core/json_utils.dart';

/// Catálogo de tipos de foto de continuidad (mockup "Continuidad
/// Visual"). Debe coincidir con TIPOS_FOTO en
/// gallery_photo_schema.py del backend.
const kTiposFoto = ['Locación', 'Propuesta', 'Prueba', 'En Rodaje'];

/// "Foto" sube cada archivo elegido como una foto de continuidad
/// separada (comportamiento de siempre). "Collage N" pide exactamente N
/// fotos y las combina en una sola imagen antes de subirla — para el
/// backend sigue siendo una foto de continuidad más, no hay modelo ni
/// endpoint nuevo (ver _buildCollage en scene_edit_screen.dart).
const kModosSubidaFoto = ['Foto', 'Collage 2', 'Collage 3', 'Collage 4'];

/// Extrae la cantidad de fotos de un modo "Collage N" (null si el modo
/// es "Foto", es decir subida normal sin combinar).
int? collageCountFor(String modoSubida) {
  if (modoSubida == 'Foto') return null;
  return int.tryParse(modoSubida.replaceAll(RegExp(r'[^0-9]'), ''));
}

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
  // Solo vienen cuando la foto se pidió desde GET /fotos (Galería
  // global del proyecto) — ver GalleryService.all(). En GET
  // /scenes/{id}/fotos quedan null porque ya se sabe de qué escena son.
  final String? numeroDeEscenaOrigen;
  final String? encabezadoEscenaOrigen;

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
    this.numeroDeEscenaOrigen,
    this.encabezadoEscenaOrigen,
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
      numeroDeEscenaOrigen: asString(pick(json, ['numero_de_escena'])),
      encabezadoEscenaOrigen: asString(pick(json, ['encabezado'])),
    );
  }
}
