import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/widgets/statistics_card.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/widgets/level_progress_circle.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final completedHabits = habitProvider.completedHabits;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF225B6A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Достижения',
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
              // Рамка с уровнем
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LevelProgressCircle(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Consumer<LevelProvider>(
                          builder: (context, levelProvider, child) {
                            final userLevel = levelProvider.userLevel;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userLevel.status,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF225B6A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${userLevel.currentXp} XP / ${userLevel.xpToNextLevel} XP до уровня ${userLevel.level + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF52B3B6),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Статистика
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StatisticsCard(),
              ),
              const SizedBox(height: 12),
              // Список архивных привычек
              Expanded(
                child: completedHabits.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет выполненных привычек',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: completedHabits.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final habit = completedHabits[index];
                          return _AchievementListItem(
                            habit: habit,
                            onRestore: () {
                              habitProvider.markHabitIncomplete(habit.id, DateTime.now());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Привычка восстановлена!')),
                              );
                            },
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
}

class _AchievementListItem extends StatefulWidget {
  final Habit habit;
  final VoidCallback onRestore;

  const _AchievementListItem({
    required this.habit,
    required this.onRestore,
  });

  @override
  State<_AchievementListItem> createState() => _AchievementListItemState();
}

class _AchievementListItemState extends State<_AchievementListItem> with SingleTickerProviderStateMixin {
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
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
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
          border: Border.all(color: const Color(0xFF52B3B6), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(widget.habit.category.icon, color: const Color(0xFF52B3B6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.habit.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF225B6A),
                    ),
                  ),
                  if (widget.habit.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
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
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF225B6A),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 6),
                      Text(
                        widget.habit.reminderTime.format(context),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restore, color: Color(0xFF52B3B6)),
              onPressed: widget.onRestore,
            ),
          ],
        ),
      ),
    );
  }
} 