import 'package:flutter/foundation.dart';
import 'package:habitgo/models/habit.dart';

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void removeHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
  }

  void updateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();
    }
  }

  void markHabitComplete(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index].completeForDate(date);
      notifyListeners();
    }
  }

  void markHabitIncomplete(String id, DateTime date) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index].uncompleteForDate(date);
      notifyListeners();
    }
  }
} 