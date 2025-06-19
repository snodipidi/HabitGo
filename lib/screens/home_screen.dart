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
                          child: habitProvider.todayHabits.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Нет привычек на сегодня.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: habitProvider.todayHabits.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final habit = habitProvider.todayHabits[index];
                                    return _HabitListItem(
                                      habit: habit,
                                      index: index,
                                      onDelete: () => _deleteHabit(habit),
                                      onComplete: () async {
                                        final levelProvider = Provider.of<LevelProvider>(context, listen: false);
                                        final xp = habit.calculateXp();
                                        habitProvider.markHabitComplete(habit.id, DateTime.now(), xp);
                                        await levelProvider.completeTask(xp);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Привычка отмечена как выполненная!')),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 28),
                        const RecommendationsSection(),
                        const SizedBox(height: 16),
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
class _HabitListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;
    final xp = habit.todayXp;
    final now = DateTime.now();
    DateTime endDateTime;
    if (habit.endTime != null) {
      endDateTime = DateTime(now.year, now.month, now.day, habit.endTime!.hour, habit.endTime!.minute);
    } else {
      endDateTime = DateTime(now.year, now.month, now.day, 23, 59);
    }
    final isExpired = now.isAfter(endDateTime);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && !isCompleted && !isExpired) {
          // Свайп вправо - отметить как выполненное
          final habitProvider = Provider.of<HabitProvider>(context, listen: false);
          habitProvider.markHabitCompletedForToday(habit.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(xp > 0 ? 'Получено $xp XP!' : 'Привычка уже выполнена сегодня'),
              backgroundColor: xp > 0 ? const Color(0xFF52B3B6) : Colors.grey,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
              ? Colors.green 
              : isExpired 
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
                  habit.category.icon,
                  color: isCompleted 
                    ? Colors.green 
                    : isExpired 
                      ? Colors.red 
                      : const Color(0xFF52B3B6),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCompleted 
                        ? Colors.green 
                        : isExpired 
                          ? Colors.red 
                          : const Color(0xFF225B6A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  )
                else if (isExpired)
                  const Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 24,
                  )
                else
                  Text(
                    '+$xp XP',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF52B3B6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            if (habit.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                habit.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted 
                    ? Colors.green.withAlpha((0.8 * 255).toInt()) 
                    : isExpired 
                      ? Colors.red.withAlpha((0.8 * 255).toInt())
                      : const Color(0xFF225B6A).withAlpha((0.8 * 255).toInt()),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

