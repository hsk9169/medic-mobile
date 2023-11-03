import 'dart:convert';
import 'dart:io';

class FileHandler {
  Future<String> convertToBase64(File file) async {
    final List<int> imageBytes = await file.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}
