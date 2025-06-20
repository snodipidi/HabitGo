import 'package:flutter/foundation.dart';
import 'package:habitgo/models/user.dart';
import 'package:habitgo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool get isInitialized => _user != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String get userName => user?.name ?? 'Пользователь';

  final AuthService _authService = AuthService();

  bool _isGoogleSignedIn = false;
  bool get isGoogleSignedIn => _isGoogleSignedIn;

  Future<void> initializeUser() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('UserProvider: Starting user initialization');
      // Проверяем Google-авторизацию через Firebase
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      _isGoogleSignedIn = firebaseUser != null;
      debugPrint('UserProvider: Google sign in status: $_isGoogleSignedIn');

      // Сначала проверяем, есть ли сохраненные данные пользователя
      _user = await User.loadFromPrefs();
      debugPrint('UserProvider: Loaded user from prefs: ${_user != null}');
      if (_user != null) {
        debugPrint('UserProvider: User has ${_user!.achievements.length} achievements');
      }
      
      // Если нет, проверяем авторизацию через Google
      if (_user == null && _isGoogleSignedIn) {
        debugPrint('UserProvider: No local user data, checking Google auth');
        final userData = await _authService.getSavedUserData();
        if (userData['user_name'] != null) {
          _user = User(name: userData['user_name']!);
          debugPrint('UserProvider: Created new user from Google data');
          await _user!.saveToPrefs();
          debugPrint('UserProvider: Saved new user to prefs');
        }
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserName(String name) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      if (_user == null) {
        _user = User(name: name);
      } else {
        _user!.name = name;
      }
      await _user!.saveToPrefs();
    } catch (e) {
      debugPrint('Error setting user name: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserName(String newName) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      if (_user == null) {
        _user = User(name: newName);
      } else {
        _user!.name = newName;
      }
      await _user!.saveToPrefs();
    } catch (e) {
      debugPrint('Error updating user name: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await clearUserData();
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Метод для сохранения пользователя (используется AchievementProvider)
  Future<void> saveUser() async {
    if (_user != null) {
      debugPrint('UserProvider: Saving user data');
      await _user!.saveToPrefs();
      debugPrint('UserProvider: User data saved successfully');
      notifyListeners();
    } else {
      debugPrint('UserProvider: Cannot save user data - user is null');
    }
  }

  Future<void> incrementStreak() async {
    if (_isLoading || _user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _user!.streakDays++;
      await _user!.saveToPrefs();
    } catch (e) {
      debugPrint('Error incrementing streak: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetStreak() async {
    if (_isLoading || _user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _user!.streakDays = 0;
      await _user!.saveToPrefs();
    } catch (e) {
      debugPrint('Error resetting streak: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _user?.clearUserData();
      _user = null;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoins(int amount) async {
    if (_user == null) return;
    _user!.habitCoins += amount;
    await _user!.saveToPrefs();
    notifyListeners();
  }
} 