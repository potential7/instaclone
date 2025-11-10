import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

import '../Data/firestore_methods.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import '../utils/color.dart';
import '../utils/utils.dart';
import '../models/post_model.dart';


class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isLoading = false;
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();

  // 📸 Select image source dialog
  Future<void> _selectImage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create Post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                final Uint8List? file = await pickImage(ImageSource.camera);
                if (file == null) return;
                setState(() => _file = file);
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                final Uint8List? file = await pickImage(ImageSource.gallery);
                if (file == null) {
                  print("⚠️ No image selected.");
                  return;
                }
                setState(() => _file = file);
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void clear() {
    setState(() {
      _file = null;
      _descriptionController.clear();
    });
  }

  // 🚀 Upload image to Firestore
  Future<void> postImage(String userId, String username, String profileImage) async {
    if (_file == null) {
      showSnackBar('Please select an image first', context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await FirestoreMethods().uploadPost(
        PostModel(
          description: _descriptionController.text.trim(),
          userName: username,
          profileImage: profileImage,
          userId: userId,
        ),
        _file!,
      );


      if (response == "Success") {
        showSnackBar('Post uploaded successfully!', context);
        clear();
      } else {
        showSnackBar(response, context);
      }
    } catch (e) {
      showSnackBar('Error: $e', context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
      child: IconButton(
        icon: const Icon(Icons.add_a_photo, size: 40),
        onPressed: () => _selectImage(context),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clear,
        ),
        title: const Text('Post to'),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () => postImage(user?.id ?? '', user?.userName ?? '', user?.photoUrl ?? ''),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : const SizedBox(height: 0),
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user?.photoUrl ?? ''),
                radius: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                ),
              ),
              if (_file != null)
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(_file!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
