import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits; // Get all habits
    final activeHabits = habitProvider.activeHabits;
    
    // Подсчет статистики
    final totalHabits = allHabits.length;
    final totalCompletedTasks = allHabits.fold<int>(0, (sum, habit) => sum + habit.completedDates.length);
    
    // Подсчет привычек по категориям
    final categoryStats = <String, int>{};
    for (var habit in activeHabits) {
      categoryStats[habit.category.label] = (categoryStats[habit.category.label] ?? 0) + 1;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF225B6A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStatItem(
                  'Всего\nпривычек',
                  totalHabits.toString(),
                  Icons.list_alt_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Выполненные\nзадачи',
                  totalCompletedTasks.toString(),
                  Icons.check_circle_outline_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Активные\nпривычки',
                  activeHabits.length.toString(),
                  Icons.play_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'По категориям',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF225B6A),
            ),
          ),
          const SizedBox(height: 12),
          ...categoryStats.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF52B3B6),
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF225B6A),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE1FFFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF52B3B6),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF225B6A),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 30.0,
          child: Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF52B3B6),
            ),
          ),
        ),
      ],
    );
  }
} 