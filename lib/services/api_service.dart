// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://skiniq-backend.onrender.com';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('Server timeout. Try again.');
      });
      print('POST $url: Status ${response.statusCode}');
      return response;
    } catch (e) {
      print('POST $url: Error $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('Server timeout. Try again.');
      });
      print('GET $url: Status ${response.statusCode}');
      return response;
    } catch (e) {
      print('GET $url: Error $e');
      rethrow;
    }
  }
}