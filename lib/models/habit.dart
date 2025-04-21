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

  Habit({
    String? id,
    required this.title,
    required this.description,
    List<DateTime>? completedDates,
    required this.targetDaysPerWeek,
    required this.reminderTime,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [];

  Habit copyWith({
    String? title,
    String? description,
    List<DateTime>? completedDates,
    int? targetDaysPerWeek,
    TimeOfDay? reminderTime,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
    );
  }

  void completeForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!isCompletedForDate(normalizedDate)) {
      completedDates.add(normalizedDate);
    }
  }

  void uncompleteForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    completedDates.removeWhere((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
  }

  bool isCompletedForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return completedDates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);
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
} 