import '../core/json_utils.dart';

class Project {
  final String idProject;
  final String projectName;
  final String formatoDeProduccion;
  final String genero;
  final String? sinopsis;
  final String? director;
  final int idClient;

  Project({
    required this.idProject,
    required this.projectName,
    required this.formatoDeProduccion,
    required this.genero,
    this.sinopsis,
    this.director,
    required this.idClient,
  });

  String get resumen =>
      [formatoDeProduccion, genero, if (director != null && director!.isNotEmpty) 'Dir. $director']
          .where((e) => e.isNotEmpty)
          .join(' · ');

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      idProject: asString(pick(json, ['id_project'])) ?? '',
      projectName: asString(pick(json, ['project_name'])) ?? '',
      formatoDeProduccion: asString(pick(json, ['formato_de_produccion'])) ?? '',
      genero: asString(pick(json, ['genero'])) ?? '',
      sinopsis: asString(pick(json, ['sinopsis'])),
      director: asString(pick(json, ['director'])),
      idClient: asInt(pick(json, ['id_client'])) ?? 0,
    );
  }
}

/// Formatos y géneros ofrecidos en el mockup de "Registrar Proyecto".
/// El backend los guarda como texto libre, así que estas listas son
/// solo para la UI (dropdown); no hay un catálogo en la API todavía.
const kFormatosProduccion = [
  'Largometraje',
  'Cortometraje',
  'Serie',
  'Documental',
  'Comercial',
  'Videoclip',
];

const kGenerosProduccion = [
  'Drama',
  'Comedia',
  'Thriller',
  'Terror',
  'Acción',
  'Histórico',
  'Documental',
  'Romance',
  'Ciencia ficción',
  'Otro',
];
