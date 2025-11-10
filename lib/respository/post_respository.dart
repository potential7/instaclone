import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/models/post_Model.dart';

class PostRepository {
  final _refPost = FirebaseFirestore.instance.collection('Posts');

  Future<List<PostModel>> getAllPosts() async{
    final snapshot = await _refPost.get();

    return snapshot.docs.map((doc) => PostModel.fromMap(doc)).toList();

  }
}