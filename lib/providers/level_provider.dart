import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_level.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/providers/achievement_provider.dart';

class LevelProvider with ChangeNotifier {
  UserLevel? _userLevel;
  static const String _levelKey = 'user_level';
  static const String _xpKey = 'user_xp';
  UserProvider? _userProvider;
  AchievementProvider? _achievementProvider;

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
    debugPrint('Loaded level: ${_userLevel!.level}, XP: ${_userLevel!.currentXp}, Progress: ${_userLevel!.getProgressPercentage()}');
    notifyListeners();
  }

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  void setAchievementProvider(AchievementProvider achievementProvider) {
    _achievementProvider = achievementProvider;
  }

  Future<void> completeTask(int xp) async {
    if (xp <= 0) return;
    
    debugPrint('Completing task with XP: $xp');
    debugPrint('Before - Level: ${_userLevel?.level}, XP: ${_userLevel?.currentXp}, Progress: ${_userLevel?.getProgressPercentage()}');
    
    final prefs = await SharedPreferences.getInstance();
    final prevLevel = _userLevel?.level ?? 1;
    
    // Создаем новый уровень с начисленным XP
    _userLevel = (_userLevel ?? UserLevel.initial()).addXp(xp);
    
    debugPrint('After - Level: ${_userLevel!.level}, XP: ${_userLevel!.currentXp}, Progress: ${_userLevel!.getProgressPercentage()}');
    
    // Сохраняем обновленные данные
    await prefs.setInt(_levelKey, _userLevel!.level);
    await prefs.setInt(_xpKey, _userLevel!.currentXp);
    
    // Начисляем монеты при повышении уровня
    if (_userProvider != null && _userLevel!.level > prevLevel) {
      await _userProvider!.addCoins(20 * (_userLevel!.level - prevLevel));
    }
    
    // Проверяем достижения за серию дней
    _achievementProvider?.checkStreakAchievements();
    
    // Уведомляем об изменениях
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