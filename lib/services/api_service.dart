import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

// Calls the Express backend with the current Supabase access token
class ApiService {
  static String get _baseUrl {
    final url = dotenv.env['BACKEND_URL'];
    if (url == null || url.isEmpty) {
      throw ApiException(0, 'BACKEND_URL is not set');
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static Future<dynamic> _request(String method, String path, [Map<String, dynamic>? body]) async {
    final token = SupabaseService.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw ApiException(401, 'You need to sign in first');
    }

    final request = http.Request(method, Uri.parse('$_baseUrl$path'));
    request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final streamed = await request.send().timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed);
    debugPrint('API $method $path -> ${response.statusCode}');

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final message = decoded is Map && decoded['error'] != null
          ? decoded['error'].toString()
          : 'Request failed (${response.statusCode})';
      throw ApiException(response.statusCode, message);
    }
    return decoded;
  }

  static Future<Map<String, dynamic>> connectDevice({
    required String myDeviceCode,
    required String targetCode,
  }) async {
    final data = await _request('POST', '/api/devices/connect', {
      'myDeviceCode': myDeviceCode,
      'targetCode': targetCode,
    });
    return Map<String, dynamic>.from(data);
  }

  static Future<void> renameConnection(int connectionId, String name) async {
    await _request('PATCH', '/api/devices/connections/$connectionId', {
      'connectionName': name,
    });
  }

  static Future<void> deleteConnection(int connectionId) async {
    await _request('DELETE', '/api/devices/connections/$connectionId');
  }

  static Future<Map<String, dynamic>> createSafeZone({
    required String locationName,
    String? locationAddress,
    required double locationLat,
    required double locationLng,
  }) async {
    final data = await _request('POST', '/api/safe-zones', {
      'locationName': locationName,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
    });
    return Map<String, dynamic>.from(data);
  }

  static Future<void> deleteSafeZone(int safeZoneId) async {
    await _request('DELETE', '/api/safe-zones/$safeZoneId');
  }

  static Future<void> saveBoundingBox({
    required int safeZoneId,
    required List<Map<String, double>> corners,
    String? locationName,
  }) async {
    final body = <String, dynamic>{'locationName': locationName};
    const names = ['A', 'B', 'C', 'D'];
    for (var i = 0; i < 4; i++) {
      body['point${names[i]}Lat'] = corners[i]['lat'];
      body['point${names[i]}Lng'] = corners[i]['lng'];
    }
    await _request('PUT', '/api/safe-zones/$safeZoneId/bounding-box', body);
  }
}
