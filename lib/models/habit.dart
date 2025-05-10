import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final List<DateTime> completedDates;
  final int targetDaysPerWeek;
  final TimeOfDay reminderTime;
  final bool isActive;
  final bool isCompleted;

  Habit({
    String? id,
    required this.title,
    required this.description,
    List<DateTime>? completedDates,
    required this.targetDaysPerWeek,
    required this.reminderTime,
    this.isActive = true,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [];

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<DateTime>? completedDates,
    int? targetDaysPerWeek,
    TimeOfDay? reminderTime,
    bool? isActive,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
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
    return getCompletedDaysThisWeek() / targetDaysPerWeek;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'targetDaysPerWeek': targetDaysPerWeek,
      'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
      'isActive': isActive,
      'isCompleted': isCompleted,
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
      targetDaysPerWeek: json['targetDaysPerWeek'] as int,
      reminderTime: _parseTimeOfDay(json['reminderTime'] as String),
      isActive: json['isActive'] as bool,
      isCompleted: json['isCompleted'] as bool,
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