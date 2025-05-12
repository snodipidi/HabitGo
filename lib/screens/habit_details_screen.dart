import 'package:flutter/material.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/edit_habit_screen.dart';
import 'package:habitgo/widgets/calendar_widget.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = [
      'Пн',
      'Вт',
      'Ср',
      'Чт',
      'Пт',
      'Сб',
      'Вс',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedHabit = await Navigator.push<Habit>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: habit),
                ),
              );
              if (updatedHabit != null) {
                Navigator.pop(context, updatedHabit);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(habit.category.icon),
                      const SizedBox(width: 8),
                      Text(
                        habit.category.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        'Напоминание: ${habit.reminderTime.format(context)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Дни недели:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = habit.selectedWeekdays.contains(day);
                      return Chip(
                        label: Text(weekdays[index]),
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Календарь',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          CalendarWidget(
            habit: habit,
            onDateTapped: (date) {
              if (habit.isCompletedForDate(date)) {
                habit.uncompleteForDate(date);
              } else {
                habit.completeForDate(date);
              }
            },
          ),
        ],
      ),
    );
  }
} 