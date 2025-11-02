import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/Data/storage_methods.dart';

import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧠 Upload a new post with image, metadata, and user info
  Future<String> uploadPost(PostModel post, Uint8List file) async {
    String result = 'An error occurred';
    try {
      final postId = const Uuid().v1();
      final photoUrl = await StorageMethods().uploadImageToStorage(
        'Posts',
        file,
        true,
      );
      if (photoUrl.isEmpty) {
        throw Exception('Image upload failed');
      }

      final postData = PostModel(
        postId: postId,
        userId: post.userId,
        userName: post.userName,
        profileImage: post.profileImage,
        description: post.description,
        photoUrl: photoUrl,
        likes: [],
        createdAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('Posts').doc(postId).set(postData.toMap());
      result = "Success";
    } catch (e) {
      print("🔥 Firestore uploadPost error: $e");
      result = "Failed to upload post: ${e.toString()}";
    }
    return result;
  }

  /// ❤️ Like / Unlike a post (atomic update)
  Future<void> likePost({
    required String postId,
    required String userId,
    required List likes,
  }) async {
    try {
      final postRef = _firestore.collection('Posts').doc(postId);

      if (likes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print("🔥 Firestore likePost error: $e");
    }
  }

  /// 💬 Add a comment to a post
  Future<void> postComment(CommentModel comment) async {
    try {
      if (comment.comment.trim().isEmpty) return;
      final commentId = const Uuid().v1();

      final commentData = {
        ...comment.toMap(),
        'commentId': commentId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('Posts')
          .doc(comment.postId)
          .collection('Comments')
          .doc(commentId)
          .set(commentData);
    } catch (e) {
      print("🔥 Firestore postComment error: $e");
    }
  }

  /// 🗑️ Delete a post (optional for later)
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('Posts').doc(postId).delete();
    } catch (e) {
      print("🔥 Firestore deletePost error: $e");
    }
  }
}
