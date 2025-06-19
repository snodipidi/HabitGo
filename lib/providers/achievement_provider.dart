import 'package:flutter/material.dart';
import 'package:habitgo/models/achievement.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/models/user.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/providers/habit_provider.dart';

class AchievementProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final HabitProvider _habitProvider;

  AchievementProvider(this._userProvider, this._habitProvider);

  // Проверка достижений при завершении привычки
  void checkHabitCompletionAchievements(Habit habit) {
    final user = _userProvider.user;
    if (user == null) return;

    // Проверяем достижения за завершение привычек разной длительности
    final duration = habit.duration;
    if (duration == 7 && !user.isAchievementUnlocked('habit_7_days')) {
      user.unlockAchievement('habit_7_days');
      _showAchievementNotification('Первые шаги');
    }
    if (duration == 14 && !user.isAchievementUnlocked('habit_14_days')) {
      user.unlockAchievement('habit_14_days');
      _showAchievementNotification('Настойчивость');
    }
    if (duration == 21 && !user.isAchievementUnlocked('habit_21_days')) {
      user.unlockAchievement('habit_21_days');
      _showAchievementNotification('Формирование привычки');
    }
    if (duration == 30 && !user.isAchievementUnlocked('habit_30_days')) {
      user.unlockAchievement('habit_30_days');
      _showAchievementNotification('Месяц успеха');
    }
    if (duration == 60 && !user.isAchievementUnlocked('habit_60_days')) {
      user.unlockAchievement('habit_60_days');
      _showAchievementNotification('Два месяца силы');
    }
    if (duration == 100 && !user.isAchievementUnlocked('habit_100_days')) {
      user.unlockAchievement('habit_100_days');
      _showAchievementNotification('Стодневка');
    }

    // Проверяем достижение "Быстрый старт"
    if (!user.isAchievementUnlocked('speed_runner')) {
      final createdDate = habit.createdAt;
      final firstCompletionDate = habit.completedDates.isNotEmpty 
          ? habit.completedDates.first 
          : null;
      
      if (firstCompletionDate != null && 
          firstCompletionDate.difference(createdDate).inDays == 0) {
        user.unlockAchievement('speed_runner');
        _showAchievementNotification('Быстрый старт');
      }
    }

    _userProvider.saveUser();
    notifyListeners();
  }

  // Проверка достижений за серию дней
  void checkStreakAchievements() {
    final user = _userProvider.user;
    if (user == null) return;

    final streakDays = user.streakDays;
    
    if (streakDays >= 7 && !user.isAchievementUnlocked('streak_7_days')) {
      user.unlockAchievement('streak_7_days');
      _showAchievementNotification('Неделя подряд');
    }
    if (streakDays >= 30 && !user.isAchievementUnlocked('streak_30_days')) {
      user.unlockAchievement('streak_30_days');
      _showAchievementNotification('Месяц подряд');
    }
    if (streakDays >= 100 && !user.isAchievementUnlocked('streak_100_days')) {
      user.unlockAchievement('streak_100_days');
      _showAchievementNotification('Стодневная серия');
    }

    _userProvider.saveUser();
    notifyListeners();
  }

  // Проверка достижений за количество привычек
  void checkTotalHabitsAchievements() {
    final user = _userProvider.user;
    if (user == null) return;

    final totalHabits = _habitProvider.habits.length;
    
    if (totalHabits >= 5 && !user.isAchievementUnlocked('total_habits_5')) {
      user.unlockAchievement('total_habits_5');
      _showAchievementNotification('Мультизадачность');
    }
    if (totalHabits >= 10 && !user.isAchievementUnlocked('total_habits_10')) {
      user.unlockAchievement('total_habits_10');
      _showAchievementNotification('Организатор');
    }
    if (totalHabits >= 20 && !user.isAchievementUnlocked('total_habits_20')) {
      user.unlockAchievement('total_habits_20');
      _showAchievementNotification('Мастер привычек');
    }

    _userProvider.saveUser();
    notifyListeners();
  }

  // Проверка достижений за время выполнения
  void checkTimeBasedAchievements(Habit habit, DateTime completionTime) {
    final user = _userProvider.user;
    if (user == null) return;

    final hour = completionTime.hour;
    
    // Ранняя пташка (до 8:00)
    if (hour < 8 && !user.isAchievementUnlocked('early_bird')) {
      user.unlockAchievement('early_bird');
      _showAchievementNotification('Ранняя пташка');
    }
    
    // Ночная сова (после 22:00)
    if (hour >= 22 && !user.isAchievementUnlocked('night_owl')) {
      user.unlockAchievement('night_owl');
      _showAchievementNotification('Ночная сова');
    }

    _userProvider.saveUser();
    notifyListeners();
  }

  // Проверка достижений за выходные
  void checkWeekendAchievements() {
    final user = _userProvider.user;
    if (user == null) return;

    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    
    // Проверяем, что это выходные (суббота или воскресенье)
    if ((weekday == 6 || weekday == 7) && !user.isAchievementUnlocked('weekend_warrior')) {
      // Проверяем, что все активные привычки выполнены сегодня
      final activeHabits = _habitProvider.habits.where((h) => !h.isCompleted).toList();
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final allCompleted = activeHabits.every((habit) => 
          habit.completedDates.contains(todayString));
      
      if (allCompleted && activeHabits.isNotEmpty) {
        user.unlockAchievement('weekend_warrior');
        _showAchievementNotification('Воин выходных');
        _userProvider.saveUser();
        notifyListeners();
      }
    }
  }

  // Проверка достижений за идеальную неделю
  void checkPerfectWeekAchievements() {
    final user = _userProvider.user;
    if (user == null) return;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // Проверяем, что все привычки выполнены за эту неделю
    final activeHabits = _habitProvider.habits.where((h) => !h.isCompleted).toList();
    bool perfectWeek = true;
    
    for (final habit in activeHabits) {
      final weekDates = <String>[];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        weekDates.add('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
      }
      
      final completedThisWeek = weekDates.any((date) => habit.completedDates.contains(date));
      if (!completedThisWeek) {
        perfectWeek = false;
        break;
      }
    }
    
    if (perfectWeek && activeHabits.isNotEmpty && !user.isAchievementUnlocked('perfect_week_1')) {
      user.unlockAchievement('perfect_week_1');
      _showAchievementNotification('Идеальная неделя');
      _userProvider.saveUser();
      notifyListeners();
    }
  }

  // Проверка достижений за постоянство
  void checkConsistencyAchievements() {
    final user = _userProvider.user;
    if (user == null) return;

    // Проверяем точность выполнения за последний месяц
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month - 1, 1);
    final monthEnd = DateTime(now.year, now.month, 0);
    
    final activeHabits = _habitProvider.habits.where((h) => !h.isCompleted).toList();
    if (activeHabits.isEmpty) return;
    
    double totalAccuracy = 0;
    int habitCount = 0;
    
    for (final habit in activeHabits) {
      final monthDates = <String>[];
      for (int i = 0; i < monthEnd.day; i++) {
        final date = monthStart.add(Duration(days: i));
        monthDates.add('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
      }
      
      final completedThisMonth = monthDates.where((date) => habit.completedDates.contains(date)).length;
      final accuracy = monthDates.isNotEmpty ? (completedThisMonth / monthDates.length) * 100 : 0;
      
      totalAccuracy += accuracy;
      habitCount++;
    }
    
    final averageAccuracy = habitCount > 0 ? totalAccuracy / habitCount : 0;
    
    if (averageAccuracy >= 90 && !user.isAchievementUnlocked('consistency_king')) {
      user.unlockAchievement('consistency_king');
      _showAchievementNotification('Король постоянства');
      _userProvider.saveUser();
      notifyListeners();
    }
  }

  // Метод для показа уведомления о достижении
  void _showAchievementNotification(String achievementTitle) {
    // Здесь можно добавить логику показа уведомления
    // Например, использовать flutter_local_notifications или показать SnackBar
    debugPrint('🎉 Достижение разблокировано: $achievementTitle');
  }

  // Метод для проверки всех достижений
  void checkAllAchievements() {
    checkStreakAchievements();
    checkTotalHabitsAchievements();
    checkWeekendAchievements();
    checkPerfectWeekAchievements();
    checkConsistencyAchievements();
  }

  // Метод для получения прогресса достижения
  double getAchievementProgress(String achievementId) {
    final user = _userProvider.user;
    if (user == null) return 0.0;

    final achievement = user.getAllAchievements().firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    if (achievement.isUnlocked) return 1.0;

    switch (achievement.type) {
      case AchievementType.habitCompletion:
        // Проверяем, есть ли привычки с такой длительностью
        final habitsWithDuration = _habitProvider.habits
            .where((h) => h.duration == achievement.requirement && h.isCompleted)
            .length;
        return habitsWithDuration > 0 ? 1.0 : 0.0;
        
      case AchievementType.streakDays:
        final currentStreak = user.streakDays;
        return (currentStreak / achievement.requirement).clamp(0.0, 1.0);
        
      case AchievementType.totalHabits:
        final totalHabits = _habitProvider.habits.length;
        return (totalHabits / achievement.requirement).clamp(0.0, 1.0);
        
      case AchievementType.perfectWeek:
        // Упрощенная проверка - считаем, что прогресс 0, если не достигнуто
        return 0.0;
        
      case AchievementType.earlyBird:
      case AchievementType.nightOwl:
      case AchievementType.weekendWarrior:
      case AchievementType.consistencyKing:
      case AchievementType.speedRunner:
        // Эти достижения либо разблокированы, либо нет
        return 0.0;
        
      default:
        return 0.0;
    }
  }
} 