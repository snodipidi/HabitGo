import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/habit_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/edit_habit_screen.dart';

class MyHabitsScreen extends StatelessWidget {
  const MyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1FFFC),
              Color(0xFF00A0A6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF225B6A)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Мои хобби',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF225B6A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: habitProvider.activeHabits.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет активных привычек.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: habitProvider.activeHabits.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final habit = habitProvider.activeHabits[index];
                          return _HabitListItem(
                            habit: habit,
                            index: index,
                            onDelete: () => _deleteHabit(context, habit),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHabitDetails(BuildContext context, Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      ),
    );
  }

  void _deleteHabit(BuildContext context, Habit habit) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    habitProvider.removeHabit(habit.id);
  }
}

class _HabitListItem extends StatelessWidget {
  final Habit habit;
  final int index;
  final VoidCallback onDelete;

  const _HabitListItem({
    Key? key,
    required this.habit,
    required this.index,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (habit.description.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: const Color(0xFFE1FFFC),
              title: const Text(
                'Цель/мини-задача',
                style: TextStyle(
                  color: Color(0xFF225B6A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              content: Text(
                habit.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF225B6A),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Закрыть', style: TextStyle(color: Color(0xFF52B3B6))),
                ),
              ],
            ),
          );
        }
      },
      child: Slidable(
        key: ValueKey(habit.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.8,
          children: [
            SlidableAction(
              onPressed: (_) {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                habitProvider.markHabitComplete(habit.id, DateTime.now());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Привычка отмечена как выполненная!')),
                );
              },
              backgroundColor: const Color(0xFF52B3B6),
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline_rounded,
              label: '',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              autoClose: true,
              flex: 1,
              spacing: 0,
            ),
            SlidableAction(
              onPressed: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditHabitScreen(habit: habit),
                  ),
                );
              },
              backgroundColor: const Color(0xFF225B6A),
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: '',
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              autoClose: true,
              flex: 1,
              spacing: 0,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: '',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              autoClose: true,
              flex: 1,
              spacing: 0,
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
            border: Border.all(color: const Color(0xFF52B3B6), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF225B6A),
                      ),
                    ),
                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        habit.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF225B6A),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.access_time, size: 32, color: Color(0xFF225B6A)),
                        SizedBox(width: 8),
                        Text(
                          'Сегодня',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF225B6A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(3, (i) => const Icon(
                  Icons.star,
                  color: Color(0xFF52B3B6),
                  size: 36,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 