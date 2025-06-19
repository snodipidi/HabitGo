import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/habit_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/edit_habit_screen.dart';
import 'package:habitgo/providers/category_provider.dart';

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
                    // Показываем базовые категории
                    ...categoryProvider.baseCategories.map((category) {
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
                    // Показываем пользовательские категории, если они есть
                    if (categoryProvider.customCategories.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ...categoryProvider.customCategories.map((category) {
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
                              key: ValueKey(habit.id),
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
  bool _isArchiving = false;
  
  // Переменные для отслеживания свайпов
  double _dragOffset = 0.0;
  double _maxLeftSwipeWidth = 0.0;
  static const double _actionButtonOverlap = 15.0;
  static const double _checkmarkSize = 100.0;
  static const double _checkmarkPadding = 10.0;
  static const double _swipeThreshold = 0.3; // 30% ширины экрана

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeOutQuad));
    
    // Инициализируем максимальную ширину свайпа после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _maxLeftSwipeWidth = MediaQuery.of(context).size.width * 0.4; // 2 кнопки по 20%
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isArchiving) return;
    
    setState(() {
      _dragOffset += details.delta.dx;
      // Ограничиваем максимальное смещение
      _dragOffset = _dragOffset.clamp(
        -_maxLeftSwipeWidth,
        MediaQuery.of(context).size.width,
      );
    });
  }

  Future<void> _handleHorizontalDragEnd(DragEndDetails details) async {
    if (_isArchiving) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity ?? 0;
    final threshold = screenWidth * _swipeThreshold;
    
    if (_dragOffset > threshold || velocity > 500) {
      // Начинаем процесс архивации
      setState(() {
        _isArchiving = true;
        _dragOffset = screenWidth;
      });

      // Ждем завершения анимации
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        // Архивируем привычку
        final habitProvider = Provider.of<HabitProvider>(context, listen: false);
        habitProvider.markHabitComplete(widget.habit.id, DateTime.now(), 10);
      }
    } else if (_dragOffset < -threshold || velocity < -500) {
      setState(() {
        _dragOffset = -_maxLeftSwipeWidth;
      });
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleHorizontalDragCancel() {
    if (_isArchiving) return;
    
    setState(() {
      _dragOffset = 0;
    });
  }

  Widget _buildLeftActions() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: _actionButtonOverlap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF52B3B6),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHabitScreen(habit: widget.habit),
                      ),
                    );
                    setState(() => _dragOffset = 0);
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    widget.onDelete();
                    setState(() => _dragOffset = 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteAnimation() {
    final progress = _dragOffset / MediaQuery.of(context).size.width;
    final isComplete = progress >= _swipeThreshold;
    
    return Positioned(
      left: 16,
      top: _checkmarkPadding,
      child: Container(
        width: _checkmarkSize,
        height: _checkmarkSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isComplete ? Colors.green : const Color(0xFF52B3B6),
            width: 3,
          ),
        ),
        child: CustomPaint(
          painter: CompleteAnimationPainter(
            progress: progress,
            isComplete: isComplete,
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: isComplete ? Colors.green : Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopPart() {
    return Container(
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
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.habit.completedDates.length}/${widget.habit.durationDays} дней',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF225B6A),
                ),
              ),
              Text(
                '${(widget.habit.completedDates.length / widget.habit.durationDays * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF225B6A),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52B3B6)),
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
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        widget.habit.description,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF225B6A),
        ),
      ),
    );
  }

  Widget _buildHabitContent() {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopPart(),
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
                child: _buildDescription(),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Stack(
      children: [
        // Фон с действиями для свайпа влево
        if (_dragOffset < 0) _buildLeftActions(),
        
        // Анимация выполнения для свайпа вправо
        if (_dragOffset > 0 && !_isArchiving) _buildCompleteAnimation(),
        
        // Основная карточка
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          child: Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: _handleHorizontalDragUpdate,
              onHorizontalDragEnd: _handleHorizontalDragEnd,
              onHorizontalDragCancel: _handleHorizontalDragCancel,
              onTap: _toggleExpanded,
              child: _buildHabitContent(),
            ),
          ),
        ),
      ],
    );
  }
}

class CompleteAnimationPainter extends CustomPainter {
  final double progress;
  final bool isComplete;

  CompleteAnimationPainter({
    required this.progress,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isComplete ? Colors.green : const Color(0xFF52B3B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Рисуем дугу прогресса
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5 * 3.14159, // Начальный угол
      progress * 2 * 3.14159, // Угол прогресса
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CompleteAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isComplete != isComplete;
  }
} 