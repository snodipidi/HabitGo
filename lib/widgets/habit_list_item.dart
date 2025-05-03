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
    return Slidable(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4DD0E1),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  'Сегодня к ${habit.reminderTime.format(context)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Icon(Icons.star, size: 20, color: Colors.black45),
                    Icon(Icons.star, size: 20, color: Colors.black45),
                    Icon(Icons.star, size: 20, color: Colors.black45),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
