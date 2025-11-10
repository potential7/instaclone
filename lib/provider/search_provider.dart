import 'package:flutter/cupertino.dart';
import 'package:instaclone/models/post_Model.dart';
import 'package:instaclone/models/user_model.dart';
import 'package:instaclone/respository/post_respository.dart';
import 'package:instaclone/respository/user_respository.dart';

class SearchProvider extends ChangeNotifier{
  final PostRepository _postRepo = PostRepository();
  final UserRepository _userRepo = UserRepository();


   bool _isLoading = false;
   bool _showUser = false;

   List<UserModel> _users = [];
   List<PostModel> _posts = [];

  bool get isLoading => _isLoading;
  bool get showUser => _showUser;
  List<UserModel> get users => _users;
  List<PostModel> get posts => _posts;

  Future<void> searchUser(String query) async {
    _isLoading = true;
    _showUser = true;
    notifyListeners();

    _users = await _userRepo.searchUsers(query);
    print('Fetched ${_users.length} users');
    _isLoading = false;
    notifyListeners();

  }

  Future<void> getAllPosts() async {
    _isLoading = true;
    _showUser = false;
    notifyListeners();

    _posts = await _postRepo.getAllPosts();
    _isLoading = false;
    notifyListeners();
  }



}
