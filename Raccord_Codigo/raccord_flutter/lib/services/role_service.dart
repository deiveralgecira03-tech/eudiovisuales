import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/catalog.dart';

class RoleService {
  final ApiClient api;
  RoleService(this.api);

  Future<List<RoleModel>> all() async {
    final data = await api.get('/roles');
    return asListOfMap(data).map(RoleModel.fromJson).toList();
  }

  /// Invita personas por correo a un proyecto con un rol determinado.
  /// Requiere permiso invite_users (Administrador, Director, Jefe de
  /// Departamento).
  Future<void> invite({
    required List<String> correos,
    required String idProject,
    required int idClient,
    required int idRol,
  }) async {
    await api.post('/users/invite', body: {
      'correos': correos,
      'id_project': idProject,
      'id_client': idClient,
      'id_rol': idRol,
    });
  }
}
