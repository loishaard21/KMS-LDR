import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/$endpoint');
    try {
      final response = await _client.get(url, headers: _getHeaders());
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/$endpoint');
    try {
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/$endpoint');
    try {
      final response = await _client.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/$endpoint');
    try {
      final response = await _client.delete(url, headers: _getHeaders());
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    dynamic bodyJson;
    try {
      bodyJson = jsonDecode(response.body);
    } catch (_) {
      bodyJson = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return bodyJson;
    } else {
      String message = 'API Request failed with status: $statusCode';
      if (bodyJson is Map && bodyJson.containsKey('message')) {
        message = bodyJson['message'];
      }
      throw Exception(message);
    }
  }
}
