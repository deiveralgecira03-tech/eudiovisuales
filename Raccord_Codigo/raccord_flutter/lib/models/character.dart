import '../core/json_utils.dart';

class CharacterModel {
  final String? idPersonaje;
  final String nombre;
  final int edad;
  final String codigoPersonaje;
  // Obligatorio para crear (ver character_schema.py en el backend): a
  // qué proyecto pertenece este personaje. Se fija al crear y nunca se
  // reenvía en updates (ver nota en character_controller.py).
  final String? idProject;

  CharacterModel({
    this.idPersonaje,
    required this.nombre,
    required this.edad,
    required this.codigoPersonaje,
    this.idProject,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      idPersonaje: asString(pick(json, ['id_personaje'])),
      nombre: asString(pick(json, ['nombre'])) ?? '',
      edad: asInt(pick(json, ['edad'])) ?? 0,
      codigoPersonaje: asString(pick(json, ['codigo_personaje'])) ?? '',
      idProject: asString(pick(json, ['id_project'])),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'nombre': nombre,
        'edad': edad,
        'codigo_personaje': codigoPersonaje,
        if (idProject != null) 'id_project': idProject,
      };
}

const kGenerosActor = ['masculino', 'fenemino', 'otro']; // 'fenemino': typo real del enum en BD

class ActorModel {
  final String? idActor;
  final String nombre;
  final String apellido;
  final String genero;
  final DateTime fechaDeNacimiento;

  final String tallaZapatos;
  final String anchoEspalda;
  final String pecho;
  final String cintura;
  final String cadera;
  final String largoManga;
  final String largoPierna;
  final String? tallaAnillo;
  final String? contornoCabeza;
  final String? contornoCuello;

  final String colorCabello;
  final String texturaCabello;
  final String tipoPiel;
  final String colorOjos;

  final String? alergias;
  final String? habilidadesEspeciales;
  final String? restricciones;
  final String? comentariosAdicionales;

  final String nacionalidad;
  final bool dobleRiesgo;
  final String? idPersonaje;
  // Obligatorio para crear (ver actor_schema.py en el backend).
  final String? idProject;

  ActorModel({
    this.idActor,
    required this.nombre,
    required this.apellido,
    required this.genero,
    required this.fechaDeNacimiento,
    required this.tallaZapatos,
    required this.anchoEspalda,
    required this.pecho,
    required this.cintura,
    required this.cadera,
    required this.largoManga,
    required this.largoPierna,
    this.tallaAnillo,
    this.contornoCabeza,
    this.contornoCuello,
    required this.colorCabello,
    required this.texturaCabello,
    required this.tipoPiel,
    required this.colorOjos,
    this.alergias,
    this.habilidadesEspeciales,
    this.restricciones,
    this.comentariosAdicionales,
    required this.nacionalidad,
    required this.dobleRiesgo,
    this.idPersonaje,
    this.idProject,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory ActorModel.fromJson(Map<String, dynamic> json) {
    final fecha = asString(pick(json, ['fecha_de_nacimiento']));
    return ActorModel(
      idActor: asString(pick(json, ['id_actor'])),
      nombre: asString(pick(json, ['nombre'])) ?? '',
      apellido: asString(pick(json, ['apellido'])) ?? '',
      genero: asString(pick(json, ['genero'])) ?? 'otro',
      fechaDeNacimiento: fecha != null ? (DateTime.tryParse(fecha) ?? DateTime(2000)) : DateTime(2000),
      tallaZapatos: asString(pick(json, ['talla_zapatos'])) ?? '',
      anchoEspalda: asString(pick(json, ['ancho_espalda'])) ?? '',
      pecho: asString(pick(json, ['pecho'])) ?? '',
      cintura: asString(pick(json, ['cintura'])) ?? '',
      cadera: asString(pick(json, ['cadera'])) ?? '',
      largoManga: asString(pick(json, ['largo_manga'])) ?? '',
      largoPierna: asString(pick(json, ['largo_pierna'])) ?? '',
      tallaAnillo: asString(pick(json, ['talla_anillo'])),
      contornoCabeza: asString(pick(json, ['contorno_cabeza'])),
      contornoCuello: asString(pick(json, ['contorno_cuello'])),
      colorCabello: asString(pick(json, ['color_cabello'])) ?? '',
      texturaCabello: asString(pick(json, ['textura_cabello'])) ?? '',
      tipoPiel: asString(pick(json, ['tipo_piel'])) ?? '',
      colorOjos: asString(pick(json, ['color_ojos'])) ?? '',
      alergias: asString(pick(json, ['alergias'])),
      habilidadesEspeciales: asString(pick(json, ['habilidades_especiales'])),
      restricciones: asString(pick(json, ['restricciones'])),
      comentariosAdicionales: asString(pick(json, ['comentarios_adicionales'])),
      nacionalidad: asString(pick(json, ['nacionalidad'])) ?? '',
      dobleRiesgo: asBool(pick(json, ['doble_riesgo'])) ?? false,
      idPersonaje: asString(pick(json, ['id_personaje'])),
      idProject: asString(pick(json, ['id_project'])),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'nombre': nombre,
        'apellido': apellido,
        'genero': genero,
        'fecha_de_nacimiento': fechaDeNacimiento.toIso8601String().split('T').first,
        'talla_zapatos': tallaZapatos,
        'ancho_espalda': anchoEspalda,
        'pecho': pecho,
        'cintura': cintura,
        'cadera': cadera,
        'largo_manga': largoManga,
        'largo_pierna': largoPierna,
        if (tallaAnillo != null && tallaAnillo!.isNotEmpty) 'talla_anillo': tallaAnillo,
        if (contornoCabeza != null && contornoCabeza!.isNotEmpty) 'contorno_cabeza': contornoCabeza,
        if (contornoCuello != null && contornoCuello!.isNotEmpty) 'contorno_cuello': contornoCuello,
        'color_cabello': colorCabello,
        'textura_cabello': texturaCabello,
        'tipo_piel': tipoPiel,
        'color_ojos': colorOjos,
        if (alergias != null && alergias!.isNotEmpty) 'alergias': alergias,
        if (habilidadesEspeciales != null && habilidadesEspeciales!.isNotEmpty)
          'habilidades_especiales': habilidadesEspeciales,
        if (restricciones != null && restricciones!.isNotEmpty) 'restricciones': restricciones,
        if (comentariosAdicionales != null && comentariosAdicionales!.isNotEmpty)
          'comentarios_adicionales': comentariosAdicionales,
        'nacionalidad': nacionalidad,
        'doble_riesgo': dobleRiesgo,
        if (idPersonaje != null && idPersonaje!.isNotEmpty) 'id_personaje': idPersonaje,
        if (idProject != null) 'id_project': idProject,
      };
}
