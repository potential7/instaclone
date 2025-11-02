import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Cloudinary Storage and returns its download URL.
  final String cloudName = 'dhszptzpr';
  final String uploadPreset = 'cloudinayImage';

  ///
  /// [childName] - The storage folder (e.g. 'profilePics', 'Posts')
  /// [file] - The Uint8List image file data
  /// [isPost] - Whether this is a post image (generates a unique folder name)
  ///
  /// Returns the image download URL or an empty string on error.
  Future<String> uploadImageToStorage(String childName,
      Uint8List file,
      bool isPost,) async {
    try {
      // 📁 Base reference: /childName/userId
      final String userId = _auth.currentUser?.uid ?? Uuid().v1().replaceAll('/', '_');
      final String uniqueId = Uuid().v1().replaceAll('/', '_');
      final String safeChildName = childName.replaceAll('/', '_');
      final String folderPath = safeChildName;

      final Uri uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/dhszptzpr/image/upload');
      final String base64Image = base64Encode(file);

      // 🆔 If this is a post image, append a unique post ID
      final Map<String, String> body = {
        'file': 'data:image/png;base64,$base64Image',
        'upload_preset': uploadPreset,
        'public_id': isPost ? uniqueId : userId,
        'folder': folderPath,
      };

      final http.Response response = await http.post(uri, body: body);

      // ⬆️ Upload the file
      // 🧾 Parse response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("✅ Uploaded to Cloudinary: ${data['secure_url']}");
        // 🔗 Get and return download URL
        return data['secure_url'];
      } else {
        print(
            "🔥 Cloudinary upload failed (${response.statusCode}): ${response
                .body}");
        return '';
      }
    } catch (e) {
      print("🔥 Cloudinary upload error: $e");
      return '';
    }
  }

}




