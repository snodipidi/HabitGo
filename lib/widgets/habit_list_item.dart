import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/add_habit_screen.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;
  final int index;
  const HabitListItem({super.key, required this.habit, required this.index});

  static const List<Color> _stripeColors = [
    Color(0xFF2196F3), // blue
    Color(0xFF26C6DA), // turquoise
    Color(0xFFFFB74D), // orange
    Color(0xFFAB47BC), // purple
  ];

  @override
  Widget build(BuildContext context) {
    final stripeColor = _stripeColors[index % _stripeColors.length];
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Slidable(
        key: ValueKey(habit.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.7,
          children: [
            SlidableAction(
              onPressed: (_) {
                habitProvider.markHabitComplete(habit.id, DateTime.now());
              },
              backgroundColor: const Color(0xFF26B3B6),
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Complete',
            ),
            SlidableAction(
              onPressed: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddHabitScreen(
                      habitToEdit: habit,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.grey[800]!,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) {
                final updated = habit.copyWith(isActive: false);
                habitProvider.updateHabit(updated);
              },
              backgroundColor: Colors.grey[900]!,
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archive',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 24,
                decoration: BoxDecoration(
                  color: stripeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.description.isNotEmpty
                            ? habit.description
                            : 'Без описания',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 18, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            'Сегодня к ${habit.reminderTime.format(context)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
