import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FaceVerificationService {
  final String apiKey = 'R3KZOemkOW7uNEYxVGr9F6Z7lNYba4YB';
  final String apiSecret = 'dthGhavz5m7hm1RsjrFlKmJ152YsZ5O-';

  Future<Map<String, dynamic>> compareFaces(File idImage, File selfieImage) async {
    final url = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare');

    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['api_secret'] = apiSecret
      ..files.add(await http.MultipartFile.fromPath('image_file1', idImage.path))
      ..files.add(await http.MultipartFile.fromPath('image_file2', selfieImage.path));

    final response = await request.send();
    final result = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(result);
    } else {
      throw Exception('Face++ error: $result');
    }
  }
}
