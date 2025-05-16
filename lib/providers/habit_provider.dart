import 'package:flutter/foundation.dart';
import 'package:habitgo/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:habitgo/providers/level_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/main.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => [..._habits];
  
  // Get only active (not completed) habits
  List<Habit> get activeHabits => _habits.where((habit) => !habit.isCompleted).toList();
  
  // Get only completed habits
  List<Habit> get completedHabits => _habits.where((habit) => habit.isCompleted).toList();

  HabitProvider() {
    _loadHabits();
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

  void markHabitComplete(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: true,
      );
      _habits[index].completeForDate(date);
      _saveHabits();
      notifyListeners();

      // Award XP for completing the habit
      final levelProvider = Provider.of<LevelProvider>(navigatorKey.currentContext!, listen: false);
      levelProvider.completeTask();
    }
  }

  void markHabitIncomplete(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: false,
      );
      _habits[index].uncompleteForDate(date);
      _saveHabits();
      notifyListeners();
    }
  }
} 