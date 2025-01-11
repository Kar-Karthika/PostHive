import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // For detecting MIME type
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

class StorageMethod {
  final String cloudName = "dc17bpxe1"; // Cloudinary Cloud Name
  final String uploadPreset = "instagram"; // Upload Preset
  var uid = Uuid().v4();

  Future<String> uploadFileToStorage(String name, File file) async {
    // Validate the file
    if (!file.existsSync()) {
      throw Exception("File does not exist at path: ${file.path}");
    }

    // Detect MIME type
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) {
      throw Exception("Unable to detect MIME type: ${file.path}");
    }

    // Validate the file type (image or video)
    if (!mimeType.startsWith('image/') && !mimeType.startsWith('video/')) {
      throw Exception("File is not a valid image or video: ${file.path}");
    }

    // Cloudinary API endpoint for upload
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

    // Create a multipart request for the file upload
    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = "$name/$uid" // Store with generated uid
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ));

    // Send the request
    var response = await request.send();

    // Check the response status
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      return responseData['secure_url']; // Return the URL of the uploaded file
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception(
          "Failed to upload file: ${response.reasonPhrase}. Response: $responseBody");
    }
  }
}
