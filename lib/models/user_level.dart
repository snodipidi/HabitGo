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
    print('Adding XP: $xpGained to current XP: $currentXp');
    int newXp = currentXp + xpGained;
    int newLevel = level;
    int newXpToNextLevel = xpToNextLevel;

    while (newXp >= newXpToNextLevel) {
      newXp -= newXpToNextLevel;
      newLevel++;
      newXpToNextLevel = calculateXpToNextLevel(newLevel);
    }

    print('New level: $newLevel, New XP: $newXp, XP to next level: $newXpToNextLevel');
    return UserLevel(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newXpToNextLevel,
      status: getStatusForLevel(newLevel),
    );
  }

  double getProgressPercentage() {
    final progress = currentXp / xpToNextLevel;
    print('Calculating progress: $currentXp / $xpToNextLevel = $progress');
    return progress;
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