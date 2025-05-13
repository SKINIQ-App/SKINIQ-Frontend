import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class SkinService {
  static const String baseUrl = 'https://skiniq-backend.onrender.com';

  static Future<void> predictSkinType(String username, File image) async {
    try {
      final trimmedUsername = username.trim();
      print('Sending skin analysis request for username: $trimmedUsername, image path: ${image.path}');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/skin/analyze?username=$trimmedUsername'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to predict skin type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting skin type: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/$username'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  static Future<void> submitQuestionnaire(Map<String, dynamic> skinDetails) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/skin/questionnaire'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(skinDetails),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to submit questionnaire');
      }
    } catch (e) {
      throw Exception('Error submitting questionnaire: $e');
    }
  }
}