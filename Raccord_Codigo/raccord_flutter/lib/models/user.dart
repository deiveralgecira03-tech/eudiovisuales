import '../core/json_utils.dart';

/// Usuario en sesión (lo que devuelve /users/login dentro de "usuario").
class SessionUser {
  final int idUser;
  final String nombre;
  final String apellido;
  final String mail;
  final int idRol;
  final int? idClient;

  SessionUser({
    required this.idUser,
    required this.nombre,
    required this.apellido,
    required this.mail,
    required this.idRol,
    this.idClient,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      idUser: asInt(pick(json, ['id_user'])) ?? 0,
      nombre: asString(pick(json, ['nombre'])) ?? '',
      apellido: asString(pick(json, ['apellido'])) ?? '',
      mail: asString(pick(json, ['mail'])) ?? '',
      idRol: asInt(pick(json, ['id_rol'])) ?? 0,
      idClient: asInt(pick(json, ['id_client'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nombre': nombre,
        'apellido': apellido,
        'mail': mail,
        'id_rol': idRol,
        'id_client': idClient,
      };
}

/// Registro completo de usuario (respuesta de GET /users/{id} y de la
/// lista de /users/project/{id}).
class AppUser {
  final int idUser;
  final String nombre;
  final String apellido;
  final String? identificacion;
  final String? idIdentificacion;
  final String mail;
  final String? msisdn;
  final String? direccion;
  final String? estado;
  final int? idRol;
  final String? idDepartamento;
  final String? idProject;

  AppUser({
    required this.idUser,
    required this.nombre,
    required this.apellido,
    this.identificacion,
    this.idIdentificacion,
    required this.mail,
    this.msisdn,
    this.direccion,
    this.estado,
    this.idRol,
    this.idDepartamento,
    this.idProject,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      idUser: asInt(pick(json, ['id_user'])) ?? 0,
      nombre: asString(pick(json, ['nombre'])) ?? '',
      apellido: asString(pick(json, ['apellido'])) ?? '',
      identificacion: asString(pick(json, ['identificacion'])),
      idIdentificacion: asString(pick(json, ['id_identificacion'])),
      mail: asString(pick(json, ['mail'])) ?? '',
      msisdn: asString(pick(json, ['msisdn'])),
      direccion: asString(pick(json, ['direccion'])),
      estado: asString(pick(json, ['estado'])),
      idRol: asInt(pick(json, ['id_rol'])),
      idDepartamento: asString(pick(json, ['id_departamento'])),
      idProject: asString(pick(json, ['id_project'])),
    );
  }
}
