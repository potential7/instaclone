import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/models/user_model.dart';

class UserRepository {
  final _refuser = FirebaseFirestore.instance.collection('Users');

  Future<List<UserModel>> searchUsers(String query) async {
    // Convert query to lowercase for case-insensitive search
   
    final lowercaseQuery = query.toLowerCase();

    final snapshot = await _refuser
        .where('userName', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('userName', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')  // Fixed: \uf8ff not /uf8ff
        .get();

    return snapshot.docs.map((doc) => UserModel.fromMap(doc)).toList();
  }
}