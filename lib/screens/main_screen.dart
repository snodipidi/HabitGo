import 'package:flutter/material.dart';
import 'package:habitgo/screens/add_habit_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _showStub(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Раздел "$title" в разработке')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Привет, Алексей!',
                  style: TextStyle(
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
                // Пример карточек привычек
                const _HabitCard(
                  title: 'Прочитай 10 страниц',
                  time: 'Сегодня к 20:00',
                  stars: 3,
                ),
                const SizedBox(height: 12),
                const _HabitCard(
                  title: 'Пробежка 10 минут',
                  time: 'Сегодня к 17:00',
                  stars: 3,
                ),
                const SizedBox(height: 12),
                const _HabitCard(
                  title: 'Поиграй на гитаре',
                  time: 'Сегодня к 19:00',
                  stars: 3,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Рекомендации',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF225B6A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Добавь новое хобби или\nвыдели 5 минут на отдых',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF225B6A),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        onAdd: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
        },
        onTab: (context, index) {
          switch (index) {
            case 0:
              _showStub(context, 'Мои хобби');
              break;
            case 1:
              _showStub(context, 'Расписание');
              break;
            case 3:
              _showStub(context, 'Отложенные');
              break;
            case 4:
              _showStub(context, 'Настройки');
              break;
          }
        },
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final String title;
  final String time;
  final int stars;
  const _HabitCard({required this.title, required this.time, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF52B3B6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
                time,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF225B6A),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  stars,
                  (index) => const Icon(Icons.star, color: Color(0xFF52B3B6), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(BuildContext, int) onTab;
  const _BottomNavBar({required this.onAdd, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.check_box_rounded, color: Color(0xFF52B3B6)),
            onPressed: () => onTab(context, 0),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions, color: Color(0xFF52B3B6)),
            onPressed: () => onTab(context, 1),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF52B3B6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: onAdd,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.hourglass_bottom, color: Color(0xFF52B3B6)),
            onPressed: () => onTab(context, 3),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF52B3B6)),
            onPressed: () => onTab(context, 4),
          ),
        ],
      ),
    );
  }
} 