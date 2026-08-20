import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/shooting_day.dart';

class ShootingDayService {
  final ApiClient api;
  ShootingDayService(this.api);

  Future<List<ShootingDay>> all() async {
    final data = await api.get('/shooting-days');
    return asListOfMap(data).map(ShootingDay.fromJson).toList();
  }

  Future<ShootingDay> create(ShootingDay day) async {
    final data = await api.post('/shooting-days', body: day.toCreateJson());
    if (data is Map) return ShootingDay.fromJson(Map<String, dynamic>.from(data));
    return day;
  }

  Future<void> delete(String id) async {
    await api.delete('/shooting-days/$id');
  }
}
