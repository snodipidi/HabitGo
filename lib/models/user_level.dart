import 'package:flutter/foundation.dart';

class UserLevel {
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final String status;

  UserLevel({
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.status,
  });

  static const int baseXpPerTask = 20;
  static const int xpMultiplier = 50; // Additional XP per level

  static String getStatusForLevel(int level) {
    if (level == 1) return 'Новичок';
    if (level == 2) return 'Привыкающий';
    if (level == 3) return 'Старатель';
    if (level == 4) return 'Усердный';
    if (level == 5) return 'Ветеран Привычек';
    if (level == 6) return 'Мастер Рутины';
    if (level == 7) return 'Эксперт Саморазвития';
    if (level == 8) return 'Великий Привычкостроитель';
    if (level == 9) return 'Легенда Привычек';
    return 'Абсолют'; // For levels 10 and above
  }

  static int calculateXpToNextLevel(int currentLevel) {
    if (currentLevel == 1) return 100;
    if (currentLevel == 2) return 150;
    if (currentLevel == 3) return 200;
    if (currentLevel == 4) return 250;
    if (currentLevel == 5) return 300;
    if (currentLevel == 6) return 350;
    if (currentLevel >= 7) return 350 + (currentLevel - 6) * 50;
    return 100; // fallback
  }

  UserLevel addXp(int xpGained) {
    if (xpGained <= 0) return this;
    
    debugPrint('Adding XP: $xpGained to current XP: $currentXp');
    int newXp = currentXp + xpGained;
    int newLevel = level;
    int newXpToNextLevel = xpToNextLevel;

    // Проверяем, достаточно ли XP для повышения уровня
    while (newXp >= newXpToNextLevel) {
      newXp -= newXpToNextLevel;
      newLevel++;
      newXpToNextLevel = calculateXpToNextLevel(newLevel);
    }

    debugPrint('New level: $newLevel, New XP: $newXp, XP to next level: $newXpToNextLevel');
    return UserLevel(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newXpToNextLevel,
      status: getStatusForLevel(newLevel),
    );
  }

  double getProgressPercentage() {
    if (xpToNextLevel <= 0) return 0.0;
    final progress = currentXp / xpToNextLevel;
    debugPrint('Calculating progress: $currentXp / $xpToNextLevel = $progress');
    return progress.clamp(0.0, 1.0);
  }

  factory UserLevel.initial() {
    return UserLevel(
      level: 1,
      currentXp: 0,
      xpToNextLevel: calculateXpToNextLevel(1),
      status: getStatusForLevel(1),
    );
  }
} 