import 'package:flutter/foundation.dart';
import 'package:habitgo/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool get isInitialized => _user != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initializeUser() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _user = await User.loadFromPrefs();
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

  Future<void> addAchievement(String achievement) async {
    if (_isLoading || _user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      if (!_user!.achievements.contains(achievement)) {
        _user!.achievements.add(achievement);
        await _user!.saveToPrefs();
      }
    } catch (e) {
      debugPrint('Error adding achievement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
} 