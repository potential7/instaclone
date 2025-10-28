import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaclone/Data/storage_methods.dart';

import '../models/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧠 Get the current user's full data from Firestore
  Future<UserModel?> getUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final snapshot = await _firestore.collection('Users').doc(currentUser.uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;

    return UserModel.fromMap(snapshot);
  }

  /// ✨ Register a new user with FirebaseAuth + Firestore + Storage
  Future<String> signUpUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String result = 'Some error occurred';

    try {
      if (email.isEmpty || password.isEmpty || bio.isEmpty || userName.isEmpty) {
        return 'Please fill all fields';
      }

      // Create account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Upload profile image
      final photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', file, false);

      // Create user model
      final newUser = UserModel(
        id: uid,
        email: email,
        userName: userName,
        bio: bio,
        photoUrl: photoUrl,
        followers: [],
        followings: [],
      );

      // Save to Firestore
      await _firestore.collection('Users').doc(uid).set(newUser.toMap());

      result = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        result = 'Email already in use';
      } else if (e.code == 'weak-password') {
        result = 'Password should be at least 6 characters';
      } else {
        result = e.message ?? 'Firebase Auth error';
      }
    } catch (e) {
      result = e.toString();
    }

    return result;
  }

  /// 🔐 Log in existing user
  Future<String> loginUser(String email, String password) async {
    String result = 'Something went wrong';
    try {
      if (email.isEmpty || password.isEmpty) {
        return 'Please fill all fields';
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      result = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        result = 'Incorrect password';
      } else {
        result = e.message ?? 'Firebase Auth error';
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  /// 🚪 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
