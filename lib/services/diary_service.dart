import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class DiaryService {
  static Future<void> uploadDiaryEntry(String userId, File image, String description, String date) async {
    var url = Uri.parse('${ApiService.baseUrl}/diary_entry');
    var request = http.MultipartRequest('POST', url);

    request.fields['user_id'] = userId;
    request.fields['description'] = description;
    request.fields['date'] = date;
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Failed to upload diary entry");
    }
  }
}