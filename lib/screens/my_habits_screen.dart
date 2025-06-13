import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/habit_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/edit_habit_screen.dart';
import 'package:habitgo/providers/category_provider.dart';
import 'package:habitgo/models/user_level.dart';

class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  String? _selectedCategory;
  String _sortBy = 'time'; // 'time' or 'name'

  List<Habit> _getFilteredAndSortedHabits(List<Habit> habits) {
    // First filter by category if one is selected
    var filteredHabits = _selectedCategory == null
        ? habits
        : habits.where((habit) => habit.category.label == _selectedCategory).toList();

    // Get today's habits
    final today = DateTime.now();
    final todayHabits = filteredHabits.where((habit) {
      final isDayOfWeek = habit.selectedWeekdays.contains(today.weekday);
      final isBeforeDeadline = habit.deadline == null || !today.isAfter(habit.deadline!);
      final isAfterCreated = !today.isBefore(habit.createdAt);
      return isDayOfWeek && isBeforeDeadline && isAfterCreated;
    }).toList();

    // Get other habits (not for today)
    final otherHabits = filteredHabits.where((habit) => !todayHabits.contains(habit)).toList();

    if (_sortBy == 'name') {
      // Sort all habits alphabetically
      final allHabits = [...todayHabits, ...otherHabits];
      allHabits.sort((a, b) => a.title.compareTo(b.title));
      return allHabits;
    } else {
      // Sort by time (default) - today's habits first
      todayHabits.sort((a, b) {
        final aTime = a.reminderTime.hour * 60 + a.reminderTime.minute;
        final bTime = b.reminderTime.hour * 60 + b.reminderTime.minute;
        return aTime.compareTo(bTime);
      });
      otherHabits.sort((a, b) {
        final aTime = a.reminderTime.hour * 60 + a.reminderTime.minute;
        final bTime = b.reminderTime.hour * 60 + b.reminderTime.minute;
        return aTime.compareTo(bTime);
      });
      return [...todayHabits, ...otherHabits];
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: true);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: true);
    final activeHabits = habitProvider.activeHabits;
    final filteredHabits = _getFilteredAndSortedHabits(activeHabits);

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
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: Color(0xFF225B6A)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'time',
                          child: Text('По времени'),
                        ),
                        const PopupMenuItem(
                          value: 'name',
                          child: Text('По названию'),
                        ),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Category filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('Все'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF52B3B6),
                      labelStyle: TextStyle(
                        color: _selectedCategory == null ? Colors.white : const Color(0xFF225B6A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...categoryProvider.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 18,
                                color: _selectedCategory == category.label
                                    ? Colors.white
                                    : const Color(0xFF52B3B6),
                              ),
                              const SizedBox(width: 4),
                              Text(category.label),
                            ],
                          ),
                          selected: _selectedCategory == category.label,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category.label : null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF52B3B6),
                          labelStyle: TextStyle(
                            color: _selectedCategory == category.label
                                ? Colors.white
                                : const Color(0xFF225B6A),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Expanded(
                child: filteredHabits.isEmpty
                    ? Center(
                        child: Text(
                          _selectedCategory == null
                              ? 'Нет активных привычек'
                              : 'Нет привычек в категории "${_selectedCategory}"',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HabitListItem(
                              habit: habit,
                              index: index,
                              onDelete: () => _deleteHabit(context, habit),
                            ),
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
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                habitProvider.markHabitComplete(habit.id, DateTime.now(), habit.calculateXp());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Привычка отмечена как выполненная!')),
                );
              },
              backgroundColor: const Color(0xFF52B3B6),
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline_rounded,
              label: '',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              autoClose: true,
              flex: 1,
              spacing: 0,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: '',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              autoClose: true,
              flex: 1,
              spacing: 0,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      habit.category.icon,
                      color: Color(0xFF52B3B6),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF225B6A),
                        ),
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${habit.calculateXp()} XP',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF52B3B6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
} 