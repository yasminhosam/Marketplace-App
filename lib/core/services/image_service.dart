import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = "detuto7ak";
    const uploadPreset = "my_preset";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    try {
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);

        return data['secure_url']; // Returns the live image link
      } else {

        final errorBody = await response.stream.bytesToString();
        print("Cloudinary Error (${response.statusCode}): $errorBody");
        return null;
      }
    } catch (e) {
      print("Network/Upload Exception: $e");
      return null;
    }
  }
}