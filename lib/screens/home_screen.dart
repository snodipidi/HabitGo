import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/widgets/habit_list_item.dart';
import 'package:habitgo/screens/add_habit_screen.dart';
import 'package:habitgo/providers/user_provider.dart';

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
        MaterialPageRoute(builder: (context) => const AddHabitScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Пользователь';

    return Scaffold(
      backgroundColor: const Color(0xFFE1FFFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1FFFC),
              Color(0xFF52B3B6),
            ],
          ),
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
                                  return HabitListItem(habit: habit);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white.withAlpha(230),
        selectedItemColor: const Color(0xFF52B3B6),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_rounded),
            label: 'Мои хобби',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_emotions),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36),
            label: 'Добавить',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_bottom),
            label: 'Отложенные',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
