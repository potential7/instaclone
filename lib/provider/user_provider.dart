
import 'package:flutter/material.dart';
import '../Data/auth_methods.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier{
  UserModel? _user;
  AuthMethods authMethods = AuthMethods();

  UserModel? get getUser => _user;
  Future<void> refreshUser()async{
    UserModel? user = await authMethods.getUserData();
    _user = user;
    notifyListeners();
  }
}