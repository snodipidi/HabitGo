import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_level.dart';

class LevelProvider with ChangeNotifier {
  UserLevel? _userLevel;
  static const String _levelKey = 'user_level';
  static const String _xpKey = 'user_xp';

  LevelProvider() {
    _loadUserLevel();
  }

  UserLevel get userLevel => _userLevel ?? UserLevel.initial();

  Future<void> _loadUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt(_levelKey) ?? 1;
    final xp = prefs.getInt(_xpKey) ?? 0;
    
    _userLevel = UserLevel(
      level: level,
      currentXp: xp,
      xpToNextLevel: UserLevel.calculateXpToNextLevel(level),
      status: UserLevel.getStatusForLevel(level),
    );
    notifyListeners();
  }

  Future<void> completeTask() async {
    final prefs = await SharedPreferences.getInstance();
    _userLevel = (_userLevel ?? UserLevel.initial()).addXp(UserLevel.baseXpPerTask);
    
    await prefs.setInt(_levelKey, _userLevel!.level);
    await prefs.setInt(_xpKey, _userLevel!.currentXp);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _userLevel = UserLevel.initial();
    
    await prefs.setInt(_levelKey, _userLevel!.level);
    await prefs.setInt(_xpKey, _userLevel!.currentXp);
    notifyListeners();
  }
} 