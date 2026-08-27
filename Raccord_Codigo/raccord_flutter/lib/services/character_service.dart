import '../core/api_client.dart';
import '../core/json_utils.dart';
import '../models/character.dart';

class CharacterService {
  final ApiClient api;
  CharacterService(this.api);

  // Antes /characters sin filtro devolvía los personajes de TODOS los
  // proyectos — ahora requiere el proyecto activo.
  Future<List<CharacterModel>> all(String idProject) async {
    final data = await api.get('/characters/project/$idProject');
    return asListOfMap(data).map(CharacterModel.fromJson).toList();
  }

  Future<CharacterModel> create(CharacterModel character) async {
    final data = await api.post('/characters', body: character.toCreateJson());
    if (data is Map) return CharacterModel.fromJson(Map<String, dynamic>.from(data));
    return character;
  }

  Future<void> update(String id, Map<String, dynamic> changes) async {
    await api.patch('/characters/$id', body: changes);
  }

  Future<void> delete(String id) async {
    await api.delete('/characters/$id');
  }
}

class ActorService {
  final ApiClient api;
  ActorService(this.api);

  // Antes /actors sin filtro devolvía los actores de TODOS los
  // proyectos — ahora requiere el proyecto activo.
  Future<List<ActorModel>> all(String idProject) async {
    final data = await api.get('/actors/project/$idProject');
    return asListOfMap(data).map(ActorModel.fromJson).toList();
  }

  Future<List<ActorModel>> byCharacter(String idPersonaje) async {
    final data = await api.get('/actors/character/$idPersonaje');
    return asListOfMap(data).map(ActorModel.fromJson).toList();
  }

  Future<ActorModel> create(ActorModel actor) async {
    final data = await api.post('/actors', body: actor.toCreateJson());
    if (data is Map) return ActorModel.fromJson(Map<String, dynamic>.from(data));
    return actor;
  }

  Future<void> delete(String id) async {
    await api.delete('/actors/$id');
  }
}
