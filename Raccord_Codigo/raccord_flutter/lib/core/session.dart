import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'permissions.dart';

const _kToken = 'raccord_token';
const _kUser = 'raccord_user'; // guardamos campos sueltos, más simple que json anidado
const _kDeviceId = 'raccord_device_id';
const _kProjectId = 'raccord_project_id';
const _kProjectName = 'raccord_project_name';

/// Estado global de sesión: token JWT, usuario autenticado, proyecto
/// activo y device_id (usado por el flujo de 2FA para "recordar este
/// dispositivo", igual que localStorage.device_id en el frontend web).
///
/// Se persiste en SharedPreferences para sobrevivir a reinicios de la
/// app, y expone un [ApiClient] ya cableado con el token actual.
class AuthSession extends ChangeNotifier {
  String? _token;
  SessionUser? _user;
  String? _deviceId;
  String? _projectId;
  String? _projectName;
  bool _ready = false;

  String? get token => _token;
  SessionUser? get user => _user;
  String? get deviceId => _deviceId;
  String? get projectId => _projectId;
  String? get projectName => _projectName;
  bool get isAuthenticated => _token != null && _user != null;
  bool get hasProject => _projectId != null && _projectId!.isNotEmpty;
  bool get ready => _ready;

  bool can(String permission) => hasPermission(_user?.idRol, permission);

  late final ApiClient api = ApiClient(tokenProvider: () => _token);

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    _deviceId = prefs.getString(_kDeviceId);
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString(_kDeviceId, _deviceId!);
    }

    _token = prefs.getString(_kToken);
    final mail = prefs.getString('${_kUser}_mail');
    if (_token != null && mail != null) {
      _user = SessionUser(
        idUser: prefs.getString('${_kUser}_id') ?? '',
        nombre: prefs.getString('${_kUser}_nombre') ?? '',
        apellido: prefs.getString('${_kUser}_apellido') ?? '',
        mail: mail,
        idRol: prefs.getInt('${_kUser}_rol') ?? 0,
        idClient: prefs.getString('${_kUser}_client'),
        idDepartamento: prefs.getString('${_kUser}_departamento'),
      );
    }

    _projectId = prefs.getString(_kProjectId);
    _projectName = prefs.getString(_kProjectName);

    _ready = true;
    notifyListeners();
  }

  Future<void> setSession(String token, SessionUser user) async {
    _token = token;
    _user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString('${_kUser}_id', user.idUser);
    await prefs.setString('${_kUser}_nombre', user.nombre);
    await prefs.setString('${_kUser}_apellido', user.apellido);
    await prefs.setString('${_kUser}_mail', user.mail);
    await prefs.setInt('${_kUser}_rol', user.idRol);
    if (user.idClient != null) {
      await prefs.setString('${_kUser}_client', user.idClient!);
    }
    if (user.idDepartamento != null) {
      await prefs.setString('${_kUser}_departamento', user.idDepartamento!);
    }

    notifyListeners();
  }

  Future<void> updateUserNames(String nombre, String apellido) async {
    if (_user == null) return;
    _user = SessionUser(
      idUser: _user!.idUser,
      nombre: nombre,
      apellido: apellido,
      mail: _user!.mail,
      idRol: _user!.idRol,
      idClient: _user!.idClient,
      idDepartamento: _user!.idDepartamento,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_kUser}_nombre', nombre);
    await prefs.setString('${_kUser}_apellido', apellido);
    notifyListeners();
  }

  Future<void> setProject(Project project) async {
    _projectId = project.idProject;
    _projectName = project.projectName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProjectId, _projectId!);
    await prefs.setString(_kProjectName, _projectName!);

    notifyListeners();
  }

  Future<void> clearProject() async {
    _projectId = null;
    _projectName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProjectId);
    await prefs.remove(_kProjectName);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _projectId = null;
    _projectName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove('${_kUser}_id');
    await prefs.remove('${_kUser}_nombre');
    await prefs.remove('${_kUser}_apellido');
    await prefs.remove('${_kUser}_mail');
    await prefs.remove('${_kUser}_rol');
    await prefs.remove('${_kUser}_client');
    await prefs.remove('${_kUser}_departamento');
    await prefs.remove(_kProjectId);
    await prefs.remove(_kProjectName);

    notifyListeners();
  }
}
