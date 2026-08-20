import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/user.dart';

class UserService {
  final ApiClient api;
  UserService(this.api);

  Future<AppUser> get(int id) async {
    final data = await api.get('/users/$id');
    return AppUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<AppUser>> byProject(String idProject) async {
    final data = await api.get('/users/project/$idProject');
    return asListOfMap(data).map(AppUser.fromJson).toList();
  }

  Future<void> updatePartial(int id, Map<String, dynamic> changes) async {
    await api.patch('/users/$id', body: changes);
  }
}
