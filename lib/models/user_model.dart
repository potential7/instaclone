import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? userName;
  final String? bio;
  final String? email;
  final String? password;
  final String? photoUrl;
  final List<dynamic>? followers;
  final List<dynamic>? followings;

  UserModel({
    this.id,
    this.userName,
    this.bio,
    this.email,
    this.password,
    this.photoUrl,
    this.followers,
    this.followings,
  });

  /// Convert model to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'bio': bio,
      'email': email,
      'photoUrl': photoUrl,
      'followers': followers ?? [],
      'followings': followings ?? [],
    };
  }

  /// Create model from Firestore snapshot
  factory UserModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return UserModel(
      id: doc.id,
      userName: data?['userName'],
      bio: data?['bio'],
      email: data?['email'],
      photoUrl: data?['photoUrl'],
      followers: data?['followers'] ?? [],
      followings: data?['followings'] ?? [],
    );
  }
}
