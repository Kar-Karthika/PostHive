import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerr {
  final picker = ImagePicker();

  // Method to capture photos or select images from the gallery
  Future<File?> uploadImage(String inputSource) async {
    try {
      final ImageSource source =
          inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery;

      final XFile? pickerImage = await picker.pickImage(source: source);

      if (pickerImage != null) {
        return File(pickerImage.path); // Return the File object
      } else {
        print("No image selected."); // Debug message
        return null; // Handle case where user cancels selection
      }
    } catch (e) {
      print("Error picking image: $e"); // Handle errors
      return null;
    }
  }

  // Method to capture videos or select videos from the gallery
  Future<File?> uploadVideo(String inputSource) async {
    try {
      final ImageSource source =
          inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery;

      final XFile? pickerVideo = await picker.pickVideo(source: source);

      if (pickerVideo != null) {
        return File(pickerVideo.path); // Return the File object
      } else {
        print("No video selected."); // Debug message
        return null; // Handle case where user cancels selection
      }
    } catch (e) {
      print("Error picking video: $e"); // Handle errors
      return null;
    }
  }
}
