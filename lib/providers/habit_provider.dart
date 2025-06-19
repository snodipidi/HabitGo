import 'package:flutter/foundation.dart';
import 'package:habitgo/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/category_provider.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  LevelProvider? _levelProvider;
  CategoryProvider? _categoryProvider;

  List<Habit> get habits => [..._habits];
  
  // Get only active (not completed) habits
  List<Habit> get activeHabits => _habits.where((habit) => !habit.isCompleted).toList();
  
  // Get only completed habits
  List<Habit> get completedHabits => _habits.where((habit) => habit.isCompleted).toList();

  // Get habits scheduled for today
  List<Habit> get todayHabits {
    final today = DateTime.now();
    return _habits.where((habit) {
      final isDayOfWeek = habit.selectedWeekdays.contains(today.weekday);
      final isBeforeDeadline = habit.deadline == null || !today.isAfter(habit.deadline!);
      final isAfterCreated = !today.isBefore(habit.createdAt);
      return isDayOfWeek && isBeforeDeadline && isAfterCreated && !habit.isCompleted;
    }).toList();
  }

  HabitProvider() {
    _loadHabits();
  }

  void setLevelProvider(LevelProvider levelProvider) {
    _levelProvider = levelProvider;
  }

  void setCategoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList('habits') ?? [];
    _habits = habitsJson
        .map((json) => Habit.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = _habits
        .map((habit) => jsonEncode(habit.toJson()))
        .toList();
    await prefs.setStringList('habits', habitsJson);
    // Очищаем неиспользуемые категории после сохранения привычек
    _categoryProvider?.cleanupUnusedCategories();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void removeHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    _saveHabits();
    notifyListeners();
  }

  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
      _saveHabits();
      notifyListeners();
    }
  }

  void markHabitComplete(String id, DateTime date, int xp) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: true,
      );
      _habits[index].completeForDate(date);
      await _saveHabits();
      // XP больше не начисляется здесь
      notifyListeners();
    }
  }

  void markHabitIncomplete(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: false,
      );
      _habits[index].uncompleteForDate(date);
      
      // Восстанавливаем пользовательскую категорию, если она была
      final category = _habits[index].category;
      if (category.isCustom) {
        // Проверяем, существует ли уже такая категория
        final categoryProvider = _categoryProvider;
        if (categoryProvider != null) {
          final existingCategories = categoryProvider.customCategories;
          final categoryExists = existingCategories.any((c) => c.label == category.label);
          if (!categoryExists) {
            categoryProvider.addCategory(category);
          }
        }
      }
      
      _saveHabits();
      notifyListeners();
    }
  }

  // Отмечает привычку как выполненную за день
  Future<void> markHabitCompletedForToday(String id) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      if (!habit.isCompletedToday) {
        final xp = habit.todayXp;
        habit.completeForDate(DateTime.now());
        await _saveHabits();
        
        // Начисляем XP через LevelProvider
        if (_levelProvider != null && xp > 0) {
          await _levelProvider!.completeTask(xp);
        }
        
        notifyListeners();
      }
    }
  }

  // Отменяет отметку о выполнении привычки за день
  Future<void> unmarkHabitCompletedForToday(String id) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      if (habit.isCompletedToday) {
        habit.uncompleteForDate(DateTime.now());
        await _saveHabits();
        notifyListeners();
      }
    }
  }

  // Проверяет, используется ли категория в активных привычках
  bool isCategoryInUse(String categoryLabel) {
    return _habits.any((habit) => 
      habit.category.label == categoryLabel && !habit.isCompleted
    );
  }
} 