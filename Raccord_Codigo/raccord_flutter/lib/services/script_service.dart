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

  Future<void> updateEstado(int idGuion, String estado) async {
    await api.patch('/scripts/$idGuion', body: {'estado': estado});
  }

  Future<void> delete(int idGuion) async {
    await api.delete('/scripts/$idGuion');
  }
}
