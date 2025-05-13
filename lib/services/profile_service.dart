import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String username) async {
    final response = await ApiService.get('/profile/$username');
    return jsonDecode(response.body);
  }

  static Future<void> updateRoutine(String userId, List<String> routineSteps) async {
    await ApiService.post('/update_routine', {
      'user_id': userId,
      'routine': routineSteps.join(','), // assumed this format is handled by your FastAPI backend
    });
  }

  static Future<void> updateProfilePicture(String username, File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/update-profile-image/$username'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      var response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile picture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }
}