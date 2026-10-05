import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryUpload {
  static const _cloudName = 'usn6hg0h';
  static const _uploadPreset = 'herman';

  static Future<String> uploadImage(XFile file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception('ອັບໂຫລດຮູບບໍ່ສຳເລັດ (${response.statusCode})');
    }
    return jsonDecode(response.body)['secure_url'] as String;
  }


  static Future<List<String>> uploadImages(List<XFile> files) =>
      Future.wait(files.map(uploadImage));
}