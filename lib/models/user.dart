import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habitgo/models/achievement.dart';

class User {
  static const String _userKey = 'user_data';
  static const int _currentDataVersion = 2;

  String name;
  List<Achievement> achievements;
  int streakDays;
  int habitCoins;
  int _dataVersion;

  User({
    required this.name,
    this.achievements = const [],
    this.streakDays = 0,
    this.habitCoins = 0,
    int? dataVersion,
  }) : _dataVersion = dataVersion ?? _currentDataVersion;

  Map<String, dynamic> toJson() {
    return {
      'version': _dataVersion,
      'name': name,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'streakDays': streakDays,
      'habitCoins': habitCoins,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 0;
    
    // Handle data migration if needed
    if (version < _currentDataVersion) {
      // Migrate from old string-based achievements to new Achievement objects
      if (version < 2) {
        final oldAchievements = List<String>.from(json['achievements'] ?? []);
        final newAchievements = <Achievement>[];
        
        // Convert old string achievements to new format if possible
        for (final achievement in Achievement.defaultAchievements) {
          if (oldAchievements.contains(achievement.title)) {
            newAchievements.add(achievement.copyWith(isUnlocked: true));
          }
        }
        
        json['achievements'] = newAchievements.map((a) => a.toJson()).toList();
        json['version'] = _currentDataVersion;
      }
    }

    return User(
      dataVersion: json['version'] as int,
      name: json['name'] as String,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      streakDays: json['streakDays'] as int? ?? 0,
      habitCoins: json['habitCoins'] as int? ?? 0,
    );
  }

  // Метод для получения всех достижений (включая заблокированные)
  List<Achievement> getAllAchievements() {
    final allAchievements = Achievement.defaultAchievements;
    final userAchievements = <String, Achievement>{};
    
    // Создаем карту пользовательских достижений
    for (final achievement in achievements) {
      userAchievements[achievement.id] = achievement;
    }
    
    // Объединяем с дефолтными достижениями
    return allAchievements.map((achievement) {
      return userAchievements[achievement.id] ?? achievement;
    }).toList();
  }

  // Метод для разблокировки достижения
  void unlockAchievement(String achievementId) {
    debugPrint('User: Starting to unlock achievement: $achievementId');
    final allAchievements = getAllAchievements();
    debugPrint('User: Total achievements: ${allAchievements.length}');
    
    final achievement = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () {
        debugPrint('User: Achievement not found: $achievementId');
        throw Exception('Achievement not found: $achievementId');
      },
    );
    
    debugPrint('User: Found achievement: ${achievement.title}, current status: ${achievement.isUnlocked}');
    
    if (!achievement.isUnlocked) {
      final unlockedAchievement = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      
      debugPrint('User: Created unlocked achievement copy');
      
      // Удаляем старое достижение если есть
      achievements.removeWhere((a) => a.id == achievementId);
      debugPrint('User: Removed old achievement if existed');
      
      // Добавляем новое разблокированное
      achievements.add(unlockedAchievement);
      debugPrint('User: Added new unlocked achievement');
      debugPrint('User: Current achievements after unlock: ${achievements.map((a) => "${a.id}:${a.isUnlocked}").join(", ")}');
    } else {
      debugPrint('User: Achievement was already unlocked');
    }
  }

  // Метод для проверки, разблокировано ли достижение
  bool isAchievementUnlocked(String achievementId) {
    final userAchievement = achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => Achievement.defaultAchievements.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => throw Exception('Achievement not found: $achievementId'),
      ),
    );
    debugPrint('User: Checking achievement unlock status: $achievementId, isUnlocked: ${userAchievement.isUnlocked}');
    return userAchievement.isUnlocked;
  }

  // Метод для получения количества разблокированных достижений
  int get unlockedAchievementsCount => achievements.length;

  // Метод для получения общего количества достижений
  int get totalAchievementsCount => Achievement.defaultAchievements.length;

  static Future<User?> loadFromPrefs() async {
    try {
      debugPrint('User: Starting to load user data');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) {
        debugPrint('User: No saved user data found');
        return null;
      }
      
      debugPrint('User: Found saved user data: $userJson');
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userMap);
      debugPrint('User: Successfully loaded user with ${user.achievements.length} achievements');
      return user;
    } catch (e) {
      // Log error and return null
      debugPrint('Error loading user data: $e');
      return null;
    }
  }

  Future<void> saveToPrefs() async {
    try {
      debugPrint('User: Starting to save user data');
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(toJson());
      debugPrint('User: Encoded user data: $userJson');
      await prefs.setString(_userKey, userJson);
      debugPrint('User: User data saved successfully');
    } catch (e) {
      // Log error but don't throw
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
} 