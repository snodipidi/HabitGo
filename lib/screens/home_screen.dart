import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/habit_detail_screen.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitgo/screens/my_habits_screen.dart';
import 'package:habitgo/screens/schedule_screen.dart';
import 'package:habitgo/screens/archive_screen.dart';
import 'package:habitgo/providers/recommendations_provider.dart';
import 'package:habitgo/widgets/recommendations_section.dart';
import 'package:habitgo/screens/create_habit_screen.dart';
import 'package:habitgo/screens/edit_habit_screen.dart';

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
        MaterialPageRoute(builder: (context) => const ArchiveScreen()),
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
                        Text(
                          'Привет, $userName!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF225B6A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Маленькие шаги ведут\nк большим переменам.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF225B6A),
                          ),
                        ),
                        const SizedBox(height: 28),
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
                          child: habitProvider.activeHabits.isEmpty
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
                                  itemCount: habitProvider.activeHabits.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final habit = habitProvider.activeHabits[index];
                                    return _HabitListItem(
                                      habit: habit,
                                      index: index,
                                      onDelete: () => _deleteHabit(habit),
                                      onComplete: () {
                                        habitProvider.markHabitComplete(habit.id, DateTime.now());
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Привычка отмечена как выполненная!')),
                                        );
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
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) {
                _onItemTapped(index);
              },
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/icon-home.svg',
                    width: 24,
                    height: 24,
                    color: _selectedIndex == 0 ? Colors.white60 : Colors.white,
                  ),
                  label: 'Мои хобби',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_emotions),
                  label: 'Расписание',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Добавить',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Архив',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Настройки',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHabitDetails(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF52B3B6), width: 1.5),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF225B6A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Color(0xFF52B3B6)),
                    const SizedBox(width: 6),
                    Text(
                      'Сегодня к ${habit.reminderTime.format(context)}',
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
          Row(
            children: List.generate(3, (i) => const Icon(
              Icons.star,
              color: Color(0xFF52B3B6),
              size: 22,
            )),
          ),
        ],
      ),
    );
  }
}
