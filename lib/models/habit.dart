import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:habitgo/models/category.dart';

enum HabitDuration {
  easy, // 5–15 мин
  medium, // 15–45 мин
  hard, // 45+ мин
}

extension HabitDurationExtension on HabitDuration {
  int get baseXp {
    switch (this) {
      case HabitDuration.easy:
        return 10;
      case HabitDuration.medium:
        return 20;
      case HabitDuration.hard:
        return 30;
    }
  }

  String get label {
    switch (this) {
      case HabitDuration.easy:
        return 'Лёгкое (5–15 мин)';
      case HabitDuration.medium:
        return 'Среднее (15–45 мин)';
      case HabitDuration.hard:
        return 'Сложное (45+ мин)';
    }
  }
}

class Habit {
  final String id;
  final String title;
  final String description;
  final List<DateTime> completedDates;
  final List<int> selectedWeekdays; // 1 = Monday, 7 = Sunday
  final TimeOfDay reminderTime;
  final bool isActive;
  final bool isCompleted;
  final Category category;
  final HabitDuration duration;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endTime;
  final int xpPerCompletion;
  final int durationDays;

  Habit({
    String? id,
    required this.title,
    required this.description,
    List<DateTime>? completedDates,
    List<int>? selectedWeekdays,
    required this.reminderTime,
    this.isActive = true,
    this.isCompleted = false,
    Category? category,
    this.duration = HabitDuration.easy, // по умолчанию Лёгкое
    this.deadline,
    DateTime? createdAt,
    required this.startDate,
    this.endTime,
    this.xpPerCompletion = 10,
    this.durationDays = 21,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        selectedWeekdays = selectedWeekdays ?? [1, 3, 5], // По умолчанию: понедельник, среда, пятница
        category = category ?? Category(label: 'Выберите категорию', icon: Icons.category),
        createdAt = createdAt ?? DateTime.now();

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<DateTime>? completedDates,
    List<int>? selectedWeekdays,
    TimeOfDay? reminderTime,
    bool? isActive,
    bool? isCompleted,
    Category? category,
    HabitDuration? duration,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endTime,
    int? xpPerCompletion,
    int? durationDays,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endTime: endTime ?? this.endTime,
      xpPerCompletion: xpPerCompletion ?? this.xpPerCompletion,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  void completeForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!completedDates.contains(normalizedDate)) {
      completedDates.add(normalizedDate);
    }
  }

  void uncompleteForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    completedDates.removeWhere((d) => 
      d.year == normalizedDate.year && 
      d.month == normalizedDate.month && 
      d.day == normalizedDate.day
    );
  }

  bool isCompletedForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    
    // Если есть время окончания, проверяем, не истекло ли оно
    if (endTime != null) {
      final todayEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        endTime!.hour,
        endTime!.minute,
      );
      
      // Если текущее время больше времени окончания, считаем привычку невыполненной
      if (now.isAfter(todayEndTime)) {
        return false;
      }
    }
    
    return completedDates.any((d) => 
      d.year == normalizedDate.year && 
      d.month == normalizedDate.month && 
      d.day == normalizedDate.day
    );
  }

  // Проверяет, выполнена ли привычка сегодня
  bool get isCompletedToday {
    final today = DateTime.now();
    return isCompletedForDate(today);
  }

  // Получает XP за выполнение привычки сегодня
  int get todayXp {
    if (isCompletedToday) {
      return 0; // Уже выполнено сегодня
    }
    return calculateXp();
  }

  int getCompletedDaysThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return completedDates
        .where((date) =>
            date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            date.isBefore(now.add(const Duration(days: 1))))
        .length;
  }

  double getWeeklyProgress() {
    return getCompletedDaysThisWeek() / selectedWeekdays.length;
  }

  // Получает следующую запланированную дату после указанной даты
  DateTime getNextScheduledDate(DateTime after) {
    DateTime date = after;
    while (true) {
      date = date.add(const Duration(days: 1));
      if (selectedWeekdays.contains(date.weekday)) {
        return date;
      }
    }
  }

  // Подсчитывает количество пропущенных дней по расписанию
  int getMissedDaysCount() {
    final now = DateTime.now();
    DateTime current = startDate;
    int missedCount = 0;

    while (current.isBefore(now)) {
      if (selectedWeekdays.contains(current.weekday)) {
        final isCompleted = completedDates.any((d) => 
          d.year == current.year && 
          d.month == current.month && 
          d.day == current.day
        );
        
        if (!isCompleted) {
          // Проверяем, истекло ли время выполнения для этого дня
          DateTime? dayEndTime;
          if (endTime != null) {
            dayEndTime = DateTime(
              current.year,
              current.month,
              current.day,
              endTime!.hour,
              endTime!.minute,
            );
          } else {
            // Если время окончания не задано, считаем концом дня 23:59
            dayEndTime = DateTime(
              current.year,
              current.month,
              current.day,
              23,
              59,
            );
          }
          
          // День считается пропущенным только если время выполнения истекло
          if (now.isAfter(dayEndTime)) {
            missedCount++;
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return missedCount;
  }

  // Проверяет, нужно ли продлить привычку
  bool needsExtension() {
    return getMissedDaysCount() > 0;
  }

  // Возвращает новую дату окончания с учетом пропущенных дней
  DateTime? getExtendedDeadline() {
    if (!needsExtension()) return deadline;
    
    final missedDays = getMissedDaysCount();
    if (deadline == null) return null;

    DateTime extendedDate = deadline!;
    int daysToAdd = 0;
    while (daysToAdd < missedDays) {
      extendedDate = getNextScheduledDate(extendedDate);
      daysToAdd++;
    }
    
    return extendedDate;
  }

  // Проверяет, является ли дата продленной (добавленной из-за пропусков)
  bool isExtendedDate(DateTime date) {
    if (!needsExtension()) return false;
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final originalEndDate = startDate.add(Duration(days: durationDays));
    
    // Дата считается продленной, если она после оригинальной даты окончания
    return normalizedDate.isAfter(originalEndDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'selectedWeekdays': selectedWeekdays,
      'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
      'isActive': isActive,
      'isCompleted': isCompleted,
      'category': category.toJson(),
      'duration': duration.index,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'xpPerCompletion': xpPerCompletion,
      'durationDays': durationDays,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completedDates: (json['completedDates'] as List)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      selectedWeekdays: (json['selectedWeekdays'] as List).map((day) => day as int).toList(),
      reminderTime: _parseTimeOfDay(json['reminderTime'] as String),
      isActive: json['isActive'] as bool,
      isCompleted: json['isCompleted'] as bool,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      duration: json['duration'] != null
          ? HabitDuration.values[json['duration'] as int]
          : HabitDuration.easy,
      deadline: json['deadline'] != null && json['deadline'] != ''
          ? DateTime.tryParse(json['deadline'])
          : null,
      createdAt: json['createdAt'] != null && json['createdAt'] != ''
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      startDate: DateTime.parse(json['startDate'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      xpPerCompletion: json['xpPerCompletion'] as int? ?? 10,
      durationDays: json['durationDays'] as int? ?? 21,
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Таблица бонусов XP по категориям
  static const Map<String, int> categoryXpBonus = {
    'Физическое здоровье': 10,
    'Психическое здоровье': 8,
    'Самообразование': 7,
    'Творчество': 5,
    'Навыки и карьера': 6,
    'Быт и дисциплина': 4,
    'Социальные действия': 6,
    'Развлечения с пользой': 2,
    'Другое': 0,
  };

  // Расчёт streakBonus
  int getStreakBonus() {
    if (completedDates.length < 2) return 0;
    // Считаем максимальную серию подряд
    final dates = completedDates.map((d) => DateTime(d.year, d.month, d.day)).toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    if (maxStreak >= 10) return 15;
    if (maxStreak >= 5) return 10;
    if (maxStreak >= 2) return 5;
    return 0;
  }

  // Расчёт полного XP за выполнение привычки
  int calculateXp() {
    final int baseXp = duration.baseXp;
    final int categoryBonus = categoryXpBonus[category.label] ?? 0;
    final int streakBonus = getStreakBonus();
    return baseXp + categoryBonus + streakBonus;
  }
} 