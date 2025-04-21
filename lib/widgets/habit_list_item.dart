import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;

  const HabitListItem({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Provider.of<HabitProvider>(context, listen: false)
                    .removeHabit(habit.id);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Удалить',
            ),
          ],
        ),
        child: Card(
          child: InkWell(
            onTap: () {
              // TODO: Implement habit details screen
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              habit.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: habit.isCompletedForDate(DateTime.now()),
                          onChanged: (bool? value) {
                            if (value == true) {
                              Provider.of<HabitProvider>(context, listen: false)
                                  .markHabitComplete(habit.id, DateTime.now());
                            } else {
                              Provider.of<HabitProvider>(context, listen: false)
                                  .markHabitIncomplete(habit.id, DateTime.now());
                            }
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: habit.getWeeklyProgress(),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      habit.getWeeklyProgress() >= 1.0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${habit.getCompletedDaysThisWeek()}/${habit.targetDaysPerWeek} дней на этой неделе',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Напоминание: ${habit.reminderTime.format(context)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 