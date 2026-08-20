import '../core/json_utils.dart';

const kEstadosGuion = ['Borrador', 'Revisión', 'Aprobado', 'En Rodaje', 'Archivado'];

class Script {
  final int? idGuion;
  final String numeroDeVersion;
  final DateTime fechaDeEmision;
  final String estado;
  final String archivo;
  final String nombre;
  final String? descripcion;
  final String? idProject;

  Script({
    this.idGuion,
    required this.numeroDeVersion,
    required this.fechaDeEmision,
    required this.estado,
    required this.archivo,
    required this.nombre,
    this.descripcion,
    this.idProject,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    final fecha = asString(pick(json, ['fecha_de_emision']));
    return Script(
      idGuion: asInt(pick(json, ['id_guion'])),
      numeroDeVersion: asString(pick(json, ['numero_de_version'])) ?? '',
      fechaDeEmision: fecha != null ? (DateTime.tryParse(fecha) ?? DateTime.now()) : DateTime.now(),
      estado: asString(pick(json, ['estado'])) ?? 'Borrador',
      archivo: asString(pick(json, ['archivo'])) ?? '',
      nombre: asString(pick(json, ['nombre'])) ?? '',
      descripcion: asString(pick(json, ['descripcion'])),
      idProject: asString(pick(json, ['id_project'])),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'numero_de_version': numeroDeVersion,
        'fecha_de_emision': fechaDeEmision.toIso8601String().split('T').first,
        'estado': estado,
        'archivo': archivo,
        'nombre': nombre,
        if (descripcion != null && descripcion!.isNotEmpty) 'descripcion': descripcion,
        if (idProject != null) 'id_project': idProject,
      };
}
