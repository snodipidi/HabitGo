import 'package:flutter/material.dart';

enum AchievementType {
  habitCompletion, // Завершение привычки определенной длительности
  streakDays, // Серия дней подряд
  totalHabits, // Общее количество привычек
  perfectWeek, // Идеальная неделя
  categoryMaster, // Мастер определенной категории
  earlyBird, // Ранняя пташка (выполнение до определенного времени)
  nightOwl, // Ночная сова (выполнение поздно)
  weekendWarrior, // Воин выходных
  consistencyKing, // Король постоянства
  speedRunner, // Быстрый старт
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int requirement; // Требуемое значение для получения
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    int? requirement,
    IconData? icon,
    Color? color,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'requirement': requirement,
      'icon': icon.codePoint,
      'color': color.value,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: AchievementType.values[json['type'] as int],
      requirement: json['requirement'] as int,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
    );
  }

  // Предустановленные достижения
  static List<Achievement> get defaultAchievements => [
    // Достижения за завершение привычек разной длительности
    Achievement(
      id: 'habit_7_days',
      title: 'Первые шаги',
      description: 'Завершите привычку длительностью 7 дней',
      type: AchievementType.habitCompletion,
      requirement: 7,
      icon: Icons.directions_walk,
      color: Colors.green,
    ),
    Achievement(
      id: 'habit_14_days',
      title: 'Настойчивость',
      description: 'Завершите привычку длительностью 14 дней',
      type: AchievementType.habitCompletion,
      requirement: 14,
      icon: Icons.trending_up,
      color: Colors.blue,
    ),
    Achievement(
      id: 'habit_21_days',
      title: 'Формирование привычки',
      description: 'Завершите привычку длительностью 21 день',
      type: AchievementType.habitCompletion,
      requirement: 21,
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    Achievement(
      id: 'habit_30_days',
      title: 'Месяц успеха',
      description: 'Завершите привычку длительностью 30 дней',
      type: AchievementType.habitCompletion,
      requirement: 30,
      icon: Icons.calendar_month,
      color: Colors.orange,
    ),
    Achievement(
      id: 'habit_60_days',
      title: 'Два месяца силы',
      description: 'Завершите привычку длительностью 60 дней',
      type: AchievementType.habitCompletion,
      requirement: 60,
      icon: Icons.fitness_center,
      color: Colors.red,
    ),
    Achievement(
      id: 'habit_100_days',
      title: 'Стодневка',
      description: 'Завершите привычку длительностью 100 дней',
      type: AchievementType.habitCompletion,
      requirement: 100,
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),

    // Достижения за серию дней
    Achievement(
      id: 'streak_7_days',
      title: 'Неделя подряд',
      description: 'Выполняйте привычки 7 дней подряд',
      type: AchievementType.streakDays,
      requirement: 7,
      icon: Icons.local_fire_department,
      color: Colors.red,
    ),
    Achievement(
      id: 'streak_30_days',
      title: 'Месяц подряд',
      description: 'Выполняйте привычки 30 дней подряд',
      type: AchievementType.streakDays,
      requirement: 30,
      icon: Icons.whatshot,
      color: Colors.orange,
    ),
    Achievement(
      id: 'streak_100_days',
      title: 'Стодневная серия',
      description: 'Выполняйте привычки 100 дней подряд',
      type: AchievementType.streakDays,
      requirement: 100,
      icon: Icons.local_fire_department,
      color: Colors.red,
    ),

    // Достижения за количество привычек
    Achievement(
      id: 'total_habits_5',
      title: 'Мультизадачность',
      description: 'Создайте 5 привычек',
      type: AchievementType.totalHabits,
      requirement: 5,
      icon: Icons.list_alt,
      color: Colors.blue,
    ),
    Achievement(
      id: 'total_habits_10',
      title: 'Организатор',
      description: 'Создайте 10 привычек',
      type: AchievementType.totalHabits,
      requirement: 10,
      icon: Icons.assignment,
      color: Colors.green,
    ),
    Achievement(
      id: 'total_habits_20',
      title: 'Мастер привычек',
      description: 'Создайте 20 привычек',
      type: AchievementType.totalHabits,
      requirement: 20,
      icon: Icons.workspace_premium,
      color: Colors.purple,
    ),

    // Достижения за идеальную неделю
    Achievement(
      id: 'perfect_week_1',
      title: 'Идеальная неделя',
      description: 'Выполните все привычки за неделю',
      type: AchievementType.perfectWeek,
      requirement: 1,
      icon: Icons.star,
      color: Colors.amber,
    ),
    Achievement(
      id: 'perfect_week_4',
      title: 'Идеальный месяц',
      description: 'Выполните все привычки за 4 недели подряд',
      type: AchievementType.perfectWeek,
      requirement: 4,
      icon: Icons.stars,
      color: Colors.orange,
    ),

    // Достижения за время выполнения
    Achievement(
      id: 'early_bird',
      title: 'Ранняя пташка',
      description: 'Выполните привычку до 8:00 утра',
      type: AchievementType.earlyBird,
      requirement: 1,
      icon: Icons.wb_sunny,
      color: Colors.yellow,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Ночная сова',
      description: 'Выполните привычку после 22:00',
      type: AchievementType.nightOwl,
      requirement: 1,
      icon: Icons.nightlight,
      color: Colors.indigo,
    ),

    // Достижения за выходные
    Achievement(
      id: 'weekend_warrior',
      title: 'Воин выходных',
      description: 'Выполните все привычки в выходные',
      type: AchievementType.weekendWarrior,
      requirement: 1,
      icon: Icons.weekend,
      color: Colors.green,
    ),

    // Достижения за постоянство
    Achievement(
      id: 'consistency_king',
      title: 'Король постоянства',
      description: 'Выполняйте привычки с точностью 90%+ в течение месяца',
      type: AchievementType.consistencyKing,
      requirement: 90,
      icon: Icons.workspace_premium,
      color: Colors.amber,
    ),

    // Достижения за быстрый старт
    Achievement(
      id: 'speed_runner',
      title: 'Быстрый старт',
      description: 'Выполните привычку в первый день создания',
      type: AchievementType.speedRunner,
      requirement: 1,
      icon: Icons.flash_on,
      color: Colors.yellow,
    ),
  ];
} 