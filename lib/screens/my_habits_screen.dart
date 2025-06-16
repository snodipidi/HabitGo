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

class _HabitListItem extends StatefulWidget {
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
  State<_HabitListItem> createState() => _HabitListItemState();
}

class _HabitListItemState extends State<_HabitListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: widget.habit),
                ),
              );
            },
            backgroundColor: const Color(0xFF52B3B6),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Редактировать',
          ),
          SlidableAction(
            onPressed: (context) => widget.onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Удалить',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.habit.category.icon,
                          color: const Color(0xFF52B3B6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.habit.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF225B6A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.habit.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF225B6A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.habit.reminderTime.format(context)} – ${widget.habit.deadlineTime.format(context)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF52B3B6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  widget.habit.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF225B6A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 