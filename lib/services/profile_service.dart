import 'dart:convert';
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
}