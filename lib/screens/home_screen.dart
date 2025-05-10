import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/screens/habit_detail_screen.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitgo/screens/settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const HabitDetailScreen()),
      );
    } else if (index == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
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
                          child: habitProvider.habits.isEmpty
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
                                  itemCount: habitProvider.habits.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final habit = habitProvider.habits[index];
                                    return _HabitListItem(
                                      habit: habit,
                                      index: index,
                                      onTap: () => _showHabitDetails(context, habit),
                                      onDelete: () => _deleteHabit(habit),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Рекомендации',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE0FFFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Добавь новое хобби или\nвыдели 5 минут на отдых',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE0FFFF),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : Center(
                      child: Text(
                        _selectedIndex == 1
                            ? 'Расписание'
                            : _selectedIndex == 3
                                ? 'Отложенные'
                                : 'Настройки',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF225B6A),
                        ),
                      ),
                    ),
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
              onTap: _onItemTapped,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/icon-home.svg',
                    width: 24,
                    height: 24,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white60,
                  ),
                  label: 'Мои хобби',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_emotions),
                  label: 'Расписание',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: 'Добавить',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.hourglass_bottom),
                  label: 'Отложенные',
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
    Navigator.push(
      context,
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
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HabitListItem({
    Key? key,
    required this.habit,
    required this.index,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Slidable(
          key: ValueKey(habit.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.8,
            children: [
              SlidableAction(
                onPressed: (_) {
                  // Выполнить привычку
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
                  // Редактировать привычку
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(habit: habit),
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
                // Expanded column with title and time
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
                // Stars
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
      ),
    );
  }
}
