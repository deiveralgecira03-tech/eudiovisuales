import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/script.dart';

class ScriptService {
  final ApiClient api;
  ScriptService(this.api);

  Future<List<Script>> byProject(String idProject) async {
    final data = await api.get('/scripts/project/$idProject');
    return asListOfMap(data).map(Script.fromJson).toList();
  }

  Future<Script> create(Script script) async {
    final data = await api.post('/scripts', body: script.toCreateJson());
    if (data is Map) return Script.fromJson(Map<String, dynamic>.from(data));
    return script;
  }

  /// Actualización parcial (PATCH /scripts/{id}): recibe solo los campos
  /// que cambiaron (nombre, estado, numero_de_version, archivo,
  /// descripcion — ver ScriptUpdateSchema en el backend, todos
  /// opcionales).
  Future<void> update(int idGuion, Map<String, dynamic> fields) async {
    await api.patch('/scripts/$idGuion', body: fields);
  }

  Future<void> delete(int idGuion) async {
    await api.delete('/scripts/$idGuion');
  }

  /// Sube (o reemplaza) el PDF real del guion. Solo Admin/Director
  /// (permiso `upload_scripts`, el backend lo vuelve a validar del lado
  /// del servidor).
  Future<void> uploadArchivo(int idGuion, {required List<int> bytes, required String filename}) async {
    await api.postFile(
      '/scripts/$idGuion/archivo',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
      contentType: 'application/pdf',
    );
  }

  /// Descarga los bytes del PDF ya cargado, para mostrarlos en el
  /// visor embebido (SfPdfViewer.memory).
  Future<List<int>> archivoBytes(int idGuion) {
    return api.getBytes('/scripts/$idGuion/archivo');
  }
}
