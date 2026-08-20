import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/breakdown.dart';

class BreakdownService {
  final ApiClient api;
  BreakdownService(this.api);

  Future<List<DesgloseItem>> itemsByScene(String idEscena) async {
    final data = await api.get('/breakdown/items/scene/$idEscena');
    return asListOfMap(data).map(DesgloseItem.fromJson).toList();
  }

  Future<DesgloseItem> createItem(DesgloseItem item) async {
    final data = await api.post('/breakdown/items', body: item.toCreateJson());
    if (data is Map) return DesgloseItem.fromJson(Map<String, dynamic>.from(data));
    return item;
  }

  Future<void> deleteItem(int id) async {
    await api.delete('/breakdown/items/$id');
  }

  Future<List<Map<String, dynamic>>> pendientesMiDepartamento() async {
    final data = await api.get('/breakdown/pendientes');
    return asListOfMap(data);
  }

  // Contenedor "desgloses" (breakdown-sheets)
  Future<List<BreakdownSheet>> sheets() async {
    final data = await api.get('/breakdown-sheets');
    return asListOfMap(data).map(BreakdownSheet.fromJson).toList();
  }

  Future<BreakdownSheet> createSheet(BreakdownSheet sheet) async {
    final data = await api.post('/breakdown-sheets', body: sheet.toCreateJson());
    if (data is Map) return BreakdownSheet.fromJson(Map<String, dynamic>.from(data));
    return sheet;
  }
}
