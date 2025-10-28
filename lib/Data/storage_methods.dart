import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Firebase Storage and returns its download URL.
  ///
  /// [childName] - The storage folder (e.g. 'profilePics', 'Posts')
  /// [file] - The Uint8List image file data
  /// [isPost] - Whether this is a post image (generates a unique folder name)
  ///
  /// Returns the image download URL or an empty string on error.
  Future<String> uploadImageToStorage(
      String childName,
      Uint8List file,
      bool isPost,
      ) async {
    try {
      // 📁 Base reference: /childName/userId
      Reference ref = _storage.ref().child(childName).child(_auth.currentUser!.uid);

      // 🆔 If this is a post image, append a unique post ID
      if (isPost) {
        final String postId = const Uuid().v1();
        ref = ref.child(postId);
      }

      // ⬆️ Upload the file
      final UploadTask uploadTask = ref.putData(file);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // 🔗 Get and return download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("🔥 Firebase Storage error: ${e.code} — ${e.message}");
      return '';
    } catch (e) {
      print("🔥 Unexpected upload error: $e");
      return '';
    }
  }

  /// Deletes an image from Firebase Storage using its download URL.
  ///
  /// [fileUrl] - The full Firebase Storage URL (e.g. from getDownloadURL()).
  ///
  /// Returns true if deletion succeeds, false otherwise.
  Future<bool> deleteImageFromStorage(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      print("✅ File deleted successfully: $fileUrl");
      return true;
    } on FirebaseException catch (e) {
      print("🔥 Firebase Storage deletion error: ${e.code} — ${e.message}");
      return false;
    } catch (e) {
      print("🔥 Unexpected deletion error: $e");
      return false;
    }
  }
}
