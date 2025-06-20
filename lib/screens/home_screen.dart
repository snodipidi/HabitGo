import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitgo/screens/my_habits_screen.dart';
import 'package:habitgo/screens/schedule_screen.dart';
import 'package:habitgo/screens/achievements_screen.dart';
import 'package:habitgo/widgets/recommendations_section.dart';
import 'package:habitgo/screens/create_habit_screen.dart';
import 'package:habitgo/screens/settings_screen.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/widgets/level_progress_circle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MyHabitsScreen()),
      );
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ScheduleScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CreateHabitScreen()),
      );
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AchievementsScreen()),
      );
    } else if (index == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  String _getWeekdayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Вс';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: true);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Пользователь';

    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(size: 48),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _selectedIndex == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: const LevelProgressCircle(),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Привет, $userName!',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF225B6A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Маленькие шаги ведут к большим переменам.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF225B6A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // Мини-календарь на неделю
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.9 * 255).toInt()),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Неделя',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF225B6A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  // Получаем понедельник текущей недели
                                  final now = DateTime.now();
                                  final monday = now.subtract(Duration(days: now.weekday - 1));
                                  final date = monday.add(Duration(days: index));
                                  final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                                  final habitsForDay = habitProvider.habits.where((habit) {
                                    if (habit.isCompleted) return false;
                                    final isDayOfWeek = habit.selectedWeekdays.contains(date.weekday);
                                    final isBeforeDeadline = habit.deadline == null || !date.isAfter(habit.deadline!);
                                    final isAfterCreated = !date.isBefore(habit.createdAt);
                                    return isDayOfWeek && isBeforeDeadline && isAfterCreated;
                                  }).toList();
                                  
                                  int completedCount = 0;
                                  int totalCount = habitsForDay.length;
                                  
                                  for (final habit in habitsForDay) {
                                    final isCompleted = habit.completedDates.any((d) => 
                                      d.year == date.year && 
                                      d.month == date.month && 
                                      d.day == date.day
                                    );
                                    if (isCompleted) completedCount++;
                                  }
                                  
                                  Color? dayColor;
                                  if (totalCount == 0) {
                                    dayColor = Colors.grey[300];
                                  } else if (completedCount == totalCount && totalCount > 0) {
                                    dayColor = Colors.green;
                                  } else if (completedCount > 0) {
                                    dayColor = Colors.yellow[700];
                                  } else if (date.isBefore(now) && date.day != now.day) {
                                    dayColor = Colors.red;
                                  } else {
                                    dayColor = const Color(0xFF52B3B6);
                                  }
                                  
                                  return Column(
                                    children: [
                                      Text(
                                        _getWeekdayShort(date.weekday),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isToday ? const Color(0xFF52B3B6) : Colors.grey[600],
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: dayColor,
                                          shape: BoxShape.circle,
                                          border: isToday ? Border.all(
                                            color: const Color(0xFF52B3B6),
                                            width: 2,
                                          ) : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${date.day}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (totalCount > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '$completedCount/$totalCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF225B6A),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Задания на день',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF225B6A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: habitProvider.todayHabits.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 32.0),
                                          child: Text(
                                            'Нет привычек на сегодня.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(
                                          habitProvider.todayHabits.length,
                                          (index) {
                                            final habit = habitProvider.todayHabits[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 12.0),
                                              child: _HabitListItem(
                                                habit: habit,
                                                index: index,
                                                onDelete: () => _deleteHabit(habit),
                                                onComplete: () async {
                                                  final levelProvider = Provider.of<LevelProvider>(context, listen: false);
                                                  final xp = habit.calculateXp();
                                                  final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                                                  await habitProvider.markHabitCompletedForToday(habit.id, context);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Привычка отмечена как выполненная!')),
                                                    );
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 28),
                              ),
                              const SliverToBoxAdapter(
                                child: RecommendationsSection(),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _selectedIndex == 1
                      ? const Center(child: Text('Расписание'))
                      : _selectedIndex == 3
                          ? const Center(child: Text('Отложенные'))
                          : const SettingsScreen(),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF52B3B6),
                Color(0xFF00A0A6),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              iconSize: 26,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white70,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) {
                _onItemTapped(index);
              },
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Align(
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      'assets/icons/sweep.svg',
                      width: 26,
                      height: 26,
                      color: Colors.white70,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Align(
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      'assets/icons/glyph.svg',
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '',
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }

  void _deleteHabit(Habit habit) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    habitProvider.removeHabit(habit.id);
  }
}

class _HabitListItem extends StatefulWidget {
  final Habit habit;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const _HabitListItem({
    required this.habit,
    required this.index,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  State<_HabitListItem> createState() => _HabitListItemState();
}

class _HabitListItemState extends State<_HabitListItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _swipeController;
  late Animation<double> _heightFactor;
  late Animation<double> _swipeFillWidth;
  bool _isExpanded = false;
  bool _isSwiping = false;

  // Переменные для состояния привычки
  late bool _isCompleted;
  late bool _isExpired;
  late int _xp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _swipeFillWidth = _swipeController.drive(CurveTween(curve: Curves.easeInOut));
    
    // Инициализируем переменные состояния
    _updateHabitState();
  }

  void _updateHabitState() {
    _isCompleted = widget.habit.isCompletedToday;
    _xp = widget.habit.todayXp;
    final now = DateTime.now();
    DateTime endDateTime;
    if (widget.habit.endTime != null) {
      endDateTime = DateTime(now.year, now.month, now.day, widget.habit.endTime!.hour, widget.habit.endTime!.minute);
    } else {
      endDateTime = DateTime(now.year, now.month, now.day, 23, 59);
    }
    _isExpired = now.isAfter(endDateTime);
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeController.dispose();
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

  Future<void> _handleHorizontalDragUpdate(DragUpdateDetails details) async {
    if (!_isCompleted && !_isExpired) {
      final containerWidth = context.size?.width ?? 0;
      final dragProgress = details.primaryDelta! / containerWidth;
      if (dragProgress > 0) {
        setState(() {
          _isSwiping = true;
          _swipeController.value = _swipeController.value + dragProgress;
        });
      }
    }
  }

  Future<void> _handleHorizontalDragEnd(DragEndDetails details) async {
    if (!_isCompleted && !_isExpired) {
      if (_swipeController.value > 0.5) {
        // Завершаем анимацию заполнения
        await _swipeController.animateTo(1.0, 
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
        
        // Получаем XP до отметки о выполнении
        final xp = widget.habit.calculateXp();
        
        // Отмечаем привычку как выполненную
        final habitProvider = Provider.of<HabitProvider>(context, listen: false);
        await habitProvider.markHabitCompletedForToday(widget.habit.id, context);
        
        // Обновляем состояние после выполнения
        _updateHabitState();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Получено $xp XP!'),
              backgroundColor: const Color(0xFF52B3B6),
            ),
          );
        }
      } else {
        // Отменяем анимацию заполнения
        await _swipeController.animateTo(0.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
      setState(() {
        _isSwiping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Обновляем состояние при каждом построении
    _updateHabitState();
    
    return GestureDetector(
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      onTap: _toggleExpanded,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCompleted 
                  ? Colors.green 
                  : _isExpired 
                    ? Colors.red 
                    : const Color(0xFF52B3B6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      widget.habit.category.icon,
                      color: _isCompleted 
                        ? Colors.green 
                        : _isExpired 
                          ? Colors.red 
                          : const Color(0xFF52B3B6),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.habit.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isCompleted 
                            ? Colors.green 
                            : _isExpired 
                              ? Colors.red 
                              : const Color(0xFF225B6A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
                    else if (_isExpired)
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 24,
                      )
                    else
                      Text(
                        '+$_xp XP',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF52B3B6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                if (widget.habit.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
                    child: Text(
                      widget.habit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCompleted 
                          ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                          : _isExpired 
                            ? Colors.red.withAlpha((0.8 * 255).toInt())
                            : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _isCompleted 
                        ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                        : _isExpired 
                          ? Colors.red.withAlpha((0.8 * 255).toInt())
                          : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.habit.reminderTime.format(context)} – ${widget.habit.endTime != null ? TimeOfDay.fromDateTime(widget.habit.endTime!).format(context) : "23:59"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isCompleted 
                          ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                          : _isExpired 
                            ? Colors.red.withAlpha((0.8 * 255).toInt())
                            : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.habit.completedDates.length}/${widget.habit.durationDays} дней',
                          style: TextStyle(
                            fontSize: 13,
                            color: _isCompleted 
                              ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                              : _isExpired 
                                ? Colors.red.withAlpha((0.8 * 255).toInt())
                                : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                          ),
                        ),
                        Text(
                          '${(widget.habit.completedDates.length / widget.habit.durationDays * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: _isCompleted 
                              ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                              : _isExpired 
                                ? Colors.red.withAlpha((0.8 * 255).toInt())
                                : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: widget.habit.completedDates.length / widget.habit.durationDays,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isCompleted 
                            ? Colors.green 
                            : _isExpired 
                              ? Colors.red 
                              : const Color(0xFF52B3B6),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    if (widget.habit.needsExtension()) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withAlpha((0.5 * 255).toInt()),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Продлено на ${widget.habit.getMissedDaysCount()} дн.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.habit.getExtendedDeadline() != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'До ${widget.habit.getExtendedDeadline()!.day}.${widget.habit.getExtendedDeadline()!.month}.${widget.habit.getExtendedDeadline()!.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_isSwiping)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _swipeController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: constraints.maxWidth * _swipeController.value,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA5D6A7).withOpacity(0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

