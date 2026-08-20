import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Envoltorio delgado sobre [http] que:
/// - arma la URL base + Bearer token en cada petición protegida
/// - decodifica el envelope {success, message, data, error} que usa
///   toda la API de Raccord (ver app/utils/response.py)
/// - convierte respuestas no exitosas en [ApiException]
class ApiClient {
  final String? Function() tokenProvider;
  final http.Client _http;

  ApiClient({required this.tokenProvider, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = ApiConfig.baseUrl;
    final full = path.startsWith('http') ? path : '$base$path';
    final uri = Uri.parse(full);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query.map((k, v) => MapEntry(k, '$v')),
    });
  }

  Map<String, String> _headers({bool auth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = tokenProvider();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await _http.get(_uri(path, query), headers: _headers(auth: auth));
    return _parse(res);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final res = await _http.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _parse(res);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final res = await _http.put(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _parse(res);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    final res = await _http.patch(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _parse(res);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final res = await _http.delete(_uri(path), headers: _headers(auth: auth));
    return _parse(res);
  }

  dynamic _parse(http.Response res) {
    Map<String, dynamic>? envelope;

    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) envelope = decoded;
      } catch (_) {
        // Respuesta no JSON (ej. error de proxy/red) -> se maneja abajo.
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (envelope == null) return null;

      if (envelope['success'] == false) {
        throw ApiException(
          envelope['message']?.toString() ?? 'La operación no fue exitosa',
          errorCode: envelope['error']?.toString(),
          statusCode: res.statusCode,
        );
      }

      return envelope['data'];
    }

    // Errores HTTP (401/403/404/422/500...). FastAPI también puede
    // responder {"detail": "..."} para errores levantados por
    // HTTPException (ej. middleware de auth), y {"detail": [...]}
    // para errores 422 de validación de Pydantic.
    String message = 'Error de conexión con el servidor (${res.statusCode})';
    String? errorCode = envelope?['error']?.toString();

    if (envelope != null) {
      final detail = envelope['detail'] ?? envelope['message'];
      if (detail is String) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          message = first['msg'].toString();
        }
      }
    }

    throw ApiException(message, errorCode: errorCode, statusCode: res.statusCode);
  }
}
