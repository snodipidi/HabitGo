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
    if (level < 5) return 'Новичок';
    if (level < 10) return 'Ученик';
    if (level < 15) return 'Практик';
    if (level < 20) return 'Мастер';
    if (level < 25) return 'Гуру';
    return 'Легенда';
  }

  static int calculateXpToNextLevel(int currentLevel) {
    return 1000 + (currentLevel * 200);
  }

  UserLevel addXp(int xpGained) {
    int newXp = currentXp + xpGained;
    int newLevel = level;
    int newXpToNextLevel = xpToNextLevel;

    while (newXp >= newXpToNextLevel) {
      newXp -= newXpToNextLevel;
      newLevel++;
      newXpToNextLevel = calculateXpToNextLevel(newLevel);
    }

    return UserLevel(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newXpToNextLevel,
      status: getStatusForLevel(newLevel),
    );
  }

  double getProgressPercentage() {
    return currentXp / xpToNextLevel;
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