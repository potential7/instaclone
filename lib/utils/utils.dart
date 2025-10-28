import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Pick image from [ImageSource.camera] or [ImageSource.gallery].
Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  final XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  } else {
    debugPrint("No image selected");
    return null;
  }
}

/// Delete an image file from local storage.
Future<void> deleteImage(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    await file.delete();
    debugPrint("Image deleted: $filePath");
  } else {
    debugPrint("Image not found: $filePath");
  }
}

/// Show snackbar message.
void showSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Push new screen on top.
void push(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => screen),
  );
}

/// Replace current screen with new one.
void pushReplacement(BuildContext context, Widget screen) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => screen),
  );
}
