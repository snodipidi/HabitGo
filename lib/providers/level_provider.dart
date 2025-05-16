import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_level.dart';
import 'package:habitgo/providers/user_provider.dart';

class LevelProvider with ChangeNotifier {
  UserLevel? _userLevel;
  static const String _levelKey = 'user_level';
  static const String _xpKey = 'user_xp';
  UserProvider? _userProvider;

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

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  Future<void> completeTask(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final prevLevel = _userLevel?.level ?? 1;
    _userLevel = (_userLevel ?? UserLevel.initial()).addXp(xp);
    await prefs.setInt(_levelKey, _userLevel!.level);
    await prefs.setInt(_xpKey, _userLevel!.currentXp);
    if (_userProvider != null && _userLevel!.level > prevLevel) {
      _userProvider!.addCoins(20 * (_userLevel!.level - prevLevel));
    }
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