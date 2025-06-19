import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Habit> _getHabitsForDay(DateTime? day, List<Habit> habits) {
    if (day == null) return [];
    return habits.where((habit) {
      // Skip completed habits
      if (habit.isCompleted) return false;
      
      final completed = habit.completedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
      final List<DateTime> scheduledDates = [];
      DateTime current = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
      int needed = habit.durationDays;
      int skips = 0;
      while (scheduledDates.length < needed) {
        if (habit.selectedWeekdays.contains(current.weekday)) {
          scheduledDates.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
      return scheduledDates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;
    final selectedHabits = _getHabitsForDay(_selectedDay, habits);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF225B6A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Расписание',
          style: TextStyle(
            color: Color(0xFF225B6A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1FFFC), Color(0xFF52B3B6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF52B3B6).withAlpha((0.3 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF52B3B6),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, color: Color(0xFF225B6A), fontWeight: FontWeight.bold),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFF225B6A)),
                    weekendStyle: TextStyle(color: Color(0xFF225B6A)),
                  ),
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    return _getHabitsForDay(day, habits);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final today = DateTime.now();
                      final habitsForDay = _getHabitsForDay(date, habits);
                      if (date.isAfter(today)) {
                        // Будущие дни
                        return null;
                      }
                      if (habitsForDay.isEmpty) {
                        // Не по расписанию
                        return null;
                      }
                      int done = 0;
                      int missed = 0;
                      int waiting = 0;
                      for (final habit in habitsForDay) {
                        final isCompleted = habit.completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                        final now = DateTime.now();
                        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                        DateTime? endDateTime;
                        if (habit.endTime != null) {
                          endDateTime = DateTime(date.year, date.month, date.day, habit.endTime!.hour, habit.endTime!.minute);
                        } else {
                          endDateTime = DateTime(date.year, date.month, date.day, 23, 59);
                        }
                        if (isCompleted) {
                          done++;
                        } else if (now.isAfter(endDateTime)) {
                          missed++;
                        } else {
                          waiting++;
                        }
                      }
                      Color? color;
                      if (done == habitsForDay.length) {
                        color = Colors.green;
                      } else if (missed == habitsForDay.length) {
                        color = Colors.red;
                      } else if (waiting > 0 || (done < habitsForDay.length && missed > 0)) {
                        color = Colors.yellow[700];
                      }
                      if (color != null) {
                        return Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                child: _buildDayView(selectedHabits),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayView(List<Habit> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: habits.isEmpty
          ? const Center(
              child: Text(
                'Нет хобби на этот день',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.separated(
              itemCount: habits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = habits[index];
                final date = _selectedDay!;
                final isCompleted = habit.completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                DateTime endDateTime;
                if (habit.endTime != null) {
                  endDateTime = DateTime(date.year, date.month, date.day, habit.endTime!.hour, habit.endTime!.minute);
                } else {
                  endDateTime = DateTime(date.year, date.month, date.day, 23, 59);
                }
                final isExpired = now.isAfter(endDateTime) && !isCompleted && date.isBefore(today.add(const Duration(days: 1)));
                final isWaiting = !isCompleted && !isExpired && (date.isAtSameMomentAs(today) || date.isAfter(today));
                Color borderColor = const Color(0xFF52B3B6);
                Icon? statusIcon;
                if (isCompleted) {
                  borderColor = Colors.green;
                  statusIcon = const Icon(Icons.check_circle, color: Colors.green, size: 24);
                } else if (isExpired) {
                  borderColor = Colors.red;
                  statusIcon = const Icon(Icons.cancel, color: Colors.red, size: 24);
                } else if (isWaiting) {
                  borderColor = Colors.yellow[700]!;
                  statusIcon = const Icon(Icons.hourglass_empty, color: Colors.yellow, size: 24);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(habit.category.icon, color: borderColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: borderColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (statusIcon != null) statusIcon,
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _HabitCard extends StatefulWidget {
  final Habit habit;

  const _HabitCard({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> with SingleTickerProviderStateMixin {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.9 * 255).toInt()),
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
                    '${widget.habit.reminderTime.format(context)} – ${widget.habit.endTime != null ? TimeOfDay.fromDateTime(widget.habit.endTime!).format(context) : "23:59"}',
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
    );
  }
} 