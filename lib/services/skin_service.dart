import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:skiniq/services/api_service.dart';

class SkinService {
  static Future<Map<String, dynamic>> predictSkinType(String username, File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/skin/analyze?username=$username'));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze skin: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during skin analysis: $e');
    }
  }

  static Future<Map<String, dynamic>> submitQuestionnaire(Map<String, dynamic> skinDetails) async {
    try {
      final response = await ApiService.post('/skin/questionnaire', skinDetails);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit questionnaire: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting questionnaire: $e');
    }
  }
}