import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  GoogleSignIn get _googleSignIn => GoogleSignIn();
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _storage.deleteAll();
  }

  // Save user data securely
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      await _storage.write(key: 'user_id', value: user.uid);
      await _storage.write(key: 'user_email', value: user.email);
      await _storage.write(key: 'user_name', value: user.displayName);
      await _storage.write(key: 'user_photo', value: user.photoURL);
    }
  }

  // Get saved user data
  Future<Map<String, String?>> getSavedUserData() async {
    return {
      'user_id': await _storage.read(key: 'user_id'),
      'user_email': await _storage.read(key: 'user_email'),
      'user_name': await _storage.read(key: 'user_name'),
      'user_photo': await _storage.read(key: 'user_photo'),
    };
  }
} 