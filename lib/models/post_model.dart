import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String? description;
  final String? id;
  final String? userName;
  final String? createdAt;
  final String? profileImage;
  final List<dynamic>? likes;
  final String? userId;
  final String? postId;
  final String? photoUrl;

  PostModel({
    this.description,
    this.photoUrl,
    this.postId,
    this.userName,
    this.createdAt,
    this.profileImage,
    this.likes,
    this.userId,
    this.id,
  });

  /// Convert model to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'userName': userName,
      'createdAt': createdAt,
      'profileImage': profileImage,
      'likes': likes,
      'photoUrl': photoUrl,
      'postId': postId,
      'userId': userId,
    };
  }

  /// Create model from Firestore snapshot
  factory PostModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return PostModel(
      id: doc.id,
      description: data?['description'],
      userName: data?['userName'],
      createdAt: data?['createdAt'],
      profileImage: (data?['profileImage'] as String?)?.isNotEmpty == true
          ? data!['profileImage'] as String
          : null,
      likes: data?['likes'] ?? [],
      photoUrl: (data?['photoUrl'] as String?)?.isNotEmpty == true
          ? data!['photoUrl'] as String
          : null,
      postId: data?['postId'],
      userId: data?['userId'],
    );
  }
}
