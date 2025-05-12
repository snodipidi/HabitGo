import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:habitgo/models/category.dart';

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
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        selectedWeekdays = selectedWeekdays ?? [1, 3, 5], // По умолчанию: понедельник, среда, пятница
        category = category ?? Category(label: 'Чтение', icon: Icons.book);

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
    return completedDates.any((d) => 
      d.year == normalizedDate.year && 
      d.month == normalizedDate.month && 
      d.day == normalizedDate.day
    );
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
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
} 