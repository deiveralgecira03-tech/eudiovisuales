import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/project.dart';

class ProjectService {
  final ApiClient api;
  ProjectService(this.api);

  Future<List<Project>> myProjects(int idUser) async {
    final data = await api.get('/users/$idUser/projects');
    return asListOfMap(data).map(Project.fromJson).toList();
  }

  Future<List<Project>> all() async {
    final data = await api.get('/projects');
    return asListOfMap(data).map(Project.fromJson).toList();
  }

  Future<Project> get(String id) async {
    final data = await api.get('/projects/$id');
    return Project.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Crea el proyecto Y lo vincula al usuario que lo crea, en un solo
  /// paso (POST /projects/create) — es lo que usan los mockups
  /// "Registra Proyecto" / "Crear Proyecto".
  Future<Project> createAndLink({
    required String projectName,
    required String formatoDeProduccion,
    required String genero,
    String? sinopsis,
    String? director,
    required int idClient,
    required int idUser,
  }) async {
    final data = await api.post('/projects/create', body: {
      'project_name': projectName,
      'formato_de_produccion': formatoDeProduccion,
      'genero': genero,
      if (sinopsis != null && sinopsis.isNotEmpty) 'sinopsis': sinopsis,
      if (director != null && director.isNotEmpty) 'director': director,
      'id_client': idClient,
      'id_user': idUser,
    });
    // El endpoint devuelve el id_project creado (string) según el
    // controller; para tener el objeto completo, se recarga la lista.
    if (data is String) {
      return get(data);
    }
    return Project.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
