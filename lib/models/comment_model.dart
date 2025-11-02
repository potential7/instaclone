import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? id;
  String comment;
  String postId;
  String userId;
  String name;
  String profilePicture;
  DateTime? createdAt;
  DateTime? updatedAt;

  CommentModel({
    this.id,
    required this.comment,
    required this.postId,
    required this.userId,
    required this.name,
    required this.profilePicture,
     this.createdAt,
     this.updatedAt,
  });

  /// ✅ Convert model to Firestore data
  Map<String, dynamic> toMap() => {
    'comment': comment,
    'postId': postId,
    'userId': userId,
    'name': name,
    'profilePicture': profilePicture,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  /// ✅ Create model from Firestore document
  factory CommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Document data is null');

    return CommentModel(
      id: doc.id,
      comment: data['comment'] ?? '',
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
