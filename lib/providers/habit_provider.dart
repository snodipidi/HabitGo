import 'package:flutter/foundation.dart';
import 'package:habitgo/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/category_provider.dart';
import 'package:flutter/material.dart';

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
    
    // Проверяем и продлеваем привычки при загрузке
    await checkAndExtendHabits();
    
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
  Future<void> markHabitCompletedForToday(String id, BuildContext context) async {
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
        
        // Проверяем, завершена ли привычка
        await checkHabitCompletion(id, context);
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

  // Проверяет и продлевает привычки с пропущенными днями
  Future<void> checkAndExtendHabits() async {
    bool hasChanges = false;
    for (final habit in _habits) {
      if (!habit.isCompleted && habit.needsExtension()) {
        final newDeadline = habit.getExtendedDeadline();
        if (newDeadline != null && (habit.deadline == null || newDeadline.isAfter(habit.deadline!))) {
          final index = _habits.indexWhere((h) => h.id == habit.id);
          if (index != -1) {
            _habits[index] = habit.copyWith(
              deadline: newDeadline,
              durationDays: habit.durationDays + habit.getMissedDaysCount(),
            );
            hasChanges = true;
          }
        }
      }
    }

    if (hasChanges) {
      await _saveHabits();
      notifyListeners();
    }
  }

  // Архивирует привычку (перемещает в достижения) с сохранением прогресса
  void archiveHabit(String id) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: true, // Перемещаем в достижения
      );
      _saveHabits();
      notifyListeners();
    }
  }

  // Восстанавливает привычку из архива с сохранением прогресса
  void restoreHabit(String id) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: false, // Возвращаем в активные привычки
      );
      
      // Восстанавливаем пользовательскую категорию, если она была
      final category = _habits[index].category;
      if (category.isCustom) {
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

  // Проверяет, завершена ли привычка и показывает диалог продления
  Future<void> checkHabitCompletion(String id, BuildContext context) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final isCompleted = habit.completedDates.length >= habit.durationDays;

    if (isCompleted && !habit.isCompleted) {
      // Показываем диалог с предложением продления
      final shouldExtend = await _showCompletionDialog(context, habit);
      
      if (shouldExtend == true) {
        // Продлеваем привычку на 7 дней
        final extendedHabit = habit.copyWith(
          durationDays: habit.durationDays + 7, // Добавляем 7 дней
          deadline: habit.getExtendedDeadline() ?? 
            DateTime.now().add(const Duration(days: 7)),
        );
        updateHabit(extendedHabit);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Привычка продлена на 7 дней!'),
              backgroundColor: Color(0xFF52B3B6),
            ),
          );
        }
      } else if (shouldExtend == false) {
        // Архивируем привычку
        archiveHabit(id);
        
        if (context.mounted) {
          _showCongratulationsDialog(context, habit);
        }
      }
    }
  }

  // Показывает диалог с предложением продления привычки
  Future<bool?> _showCompletionDialog(BuildContext context, Habit habit) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.celebration,
                color: const Color(0xFF52B3B6),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Поздравляем!',
                style: TextStyle(
                  color: Color(0xFF225B6A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вы успешно завершили привычку "${habit.title}"!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF225B6A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Хотите продолжить эту привычку еще на 7 дней?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF225B6A),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Завершить',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52B3B6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Продолжить',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Показывает диалог поздравления при завершении привычки
  void _showCongratulationsDialog(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Достижение!',
                style: TextStyle(
                  color: Color(0xFF225B6A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Привычка "${habit.title}" успешно завершена!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF225B6A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Вы выполнили ${habit.completedDates.length} из ${habit.durationDays} дней.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF52B3B6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Привычка перемещена в раздел "Достижения".',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF225B6A),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52B3B6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Отлично!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 