import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class DiaryService {
  static const String baseUrl = 'https://skiniq-backend.onrender.com';

  static Future<void> uploadDiaryEntry(
    String username,
    List<File> images,
    String text,
    String date,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diary/diary_entry'));
      request.fields['username'] = username;
      request.fields['date'] = date;
      request.fields['text'] = text;
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('file', image.path));
      }

      var response = await request.send();
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to save diary entry: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      throw Exception('Error saving diary entry: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDiaryEntries(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/diary/entries?username=$username'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch diary entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching diary entries: $e');
    }
  }
}