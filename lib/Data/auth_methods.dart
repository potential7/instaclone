import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaclone/Data/storage_methods.dart';
import '../models/user_model.dart';
import 'auth_methods.dart' as _auth;

class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;

  AuthResult.success(this.user, [this.message = 'success']) : isSuccess = true;

  AuthResult.failure(this.message) : isSuccess = false, user = null;
}

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// 🧠 Get the current user's full data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final snapshot = await _firestore
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (!snapshot.exists || snapshot.data() == null) return null;

      return UserModel.fromMap(snapshot);
    } catch (e) {
      print('🔥 Error getting user data: $e');
      return null;
    }
  }

  /// 🔐 Log in existing user
  Future<AuthResult> loginUser(String email, String password) async {
    try {
      final validationError = _validateLoginInput(email, password);
      if (validationError != null) {
        return AuthResult.failure(validationError);
      }
      // attempt sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success(userCredential.user, 'Login Successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_handleAuthException(e));
    } catch (e) {
      print('🔥 Login error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// ✨ Register a new user with FirebaseAuth + Firestore + Storage
  Future<AuthResult> signUp({
    required UserModel user,
    required Uint8List? file,
    }) async {
    try {
      final validationError = _validateSignUpInput(user, file);
      if (validationError != null) {
        return AuthResult.failure(validationError);
      }

      // create account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email!.trim(),
        password: user.password!,
      );

      final uid = userCredential.user!.uid;
      var profileUrl = await StorageMethods().uploadImageToStorage(
        'profilePics',
        file!,
        false,
      );
      if (profileUrl.isEmpty) {
        profileUrl = 'https://placehold.co/200x200';
      }

      // Create user model
      final newUser = UserModel(
        id: uid,
        email: user.email,
        userName: user.userName,
        bio: user.bio,
        photoUrl: profileUrl,
        followers: [],
        followings: [],
      );

      await _firestore.collection('Users').doc(uid).set(newUser.toMap());
      return AuthResult.success(
        userCredential.user,
        'Account Created Successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_handleAuthException(e));
    } catch (e) {
      print('🔥 Sign up error: $e');
    }
    try {
      await _auth.currentUser?.delete();
    } catch (_) {}
    return AuthResult.failure('Failed to create account: ${e.toString()}');
  }


  /// 🚪 Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('🔥 Sign out error: $e');
    }
  }
}

// validate login input

String? _validateLoginInput(String email, String password) {
  if (email.trim().isEmpty) {
    return 'email is required';
  }
  if (password.isEmpty) {
    return 'password is required';
  }
  return null;
}

String? _validateSignUpInput(UserModel user, Uint8List? file) {
  if (user.email?.trim().isEmpty ?? true) {
    return 'Email is required';
  }
  if (user.password?.isEmpty ?? true) {
    return 'Password is required';
  }
  if (user.userName?.trim().isEmpty ?? true) {
    return 'Username is required';
  }
  if (user.bio?.trim().isEmpty ?? true) {
    return 'Bio is required';
  }
  if (file == null) {
    return 'Profile picture is required';
  }
  if (user.password!.length < 6) {
    return 'Password must be at least 6 characters';
  }
  if (user.userName!.length < 3) {
    return 'Username must be at least 3 characters';
  }
  return null;
}

String _handleAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'invalid-email':
      return 'Invalid email address';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'email-already-in-use':
      return 'Email already in use';
    case 'weak-password':
      return 'Password should be at least 6 characters';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    case 'network-request-failed':
      return 'Network error. Please check your connection';
    case 'invalid-credential':
      return 'Invalid email or password';
    case 'operation-not-allowed':
      return 'Operation not allowed. Please contact support';
    default:
      return e.message ?? 'Authentication failed';
  }
}
