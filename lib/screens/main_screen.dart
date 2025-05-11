import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendations_provider.dart';
import '../widgets/recommendations_section.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              const RecommendationsSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final String title;
  final String time;
  final int stars;

  const _HabitCard({
    required this.title,
    required this.time,
    required this.stars,
  });

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