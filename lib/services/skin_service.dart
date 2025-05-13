// skin_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class SkinService {
  static Future<Map<String, dynamic>> predictSkinIssues(String symptoms) async {
    final response = await ApiService.post('/predict_skin_issues', {'symptoms': symptoms});
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> predictSkinType(File imageFile) async {
    var url = Uri.parse('${ApiService.baseUrl}/predict_skin_type');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Skin type prediction failed");
    }
  }
}
