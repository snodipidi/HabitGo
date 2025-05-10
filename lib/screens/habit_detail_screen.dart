import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/providers/habit_provider.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit? habit;

  const HabitDetailScreen({super.key, this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isCompleted = false;
  int _targetDaysPerWeek = 3;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedCategory = 0;
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.book, 'label': 'Чтение'},
    {'icon': Icons.fitness_center, 'label': 'Спорт'},
    {'icon': Icons.music_note, 'label': 'Музыка'},
    {'icon': Icons.self_improvement, 'label': 'Медитация'},
    {'icon': Icons.school, 'label': 'Учёба'},
    {'icon': Icons.more_horiz, 'label': 'Другое'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    _isCompleted = widget.habit?.isCompleted ?? false;
    _targetDaysPerWeek = widget.habit?.targetDaysPerWeek ?? 3;
    _reminderTime = widget.habit?.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      
      if (widget.habit == null) {
        // Создание новой привычки
        habitProvider.addHabit(
          Habit(
            title: _titleController.text,
            description: _descriptionController.text,
            targetDaysPerWeek: _targetDaysPerWeek,
            reminderTime: _reminderTime,
            isCompleted: _isCompleted,
          ),
        );
      } else {
        // Обновление существующей привычки
        final updatedHabit = widget.habit!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          isCompleted: _isCompleted,
        );
        habitProvider.updateHabit(updatedHabit);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                      'Добавить',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF225B6A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Название
                          const Text('Название хобби', style: TextStyle(fontSize: 17, color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Material(
                            elevation: 2,
                            shadowColor: Color(0x2252B3B6),
                            borderRadius: BorderRadius.circular(16),
                            child: TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6), width: 2),
                                ),
                              ),
                              style: const TextStyle(fontSize: 17, color: Color(0xFF225B6A)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите название';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          // Категория
                          const Text('Категория', style: TextStyle(fontSize: 17, color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 54,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final cat = _categories[i];
                                final bool selected = i == _selectedCategory;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xFF52B3B6) : const Color(0xB0E1FFFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: selected ? const Color(0xFF225B6A) : Colors.transparent, width: 2),
                                    boxShadow: selected
                                        ? [BoxShadow(color: const Color(0x3352B3B6), blurRadius: 8, offset: Offset(0, 2))]
                                        : [],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => setState(() => _selectedCategory = i),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      child: Row(
                                        children: [
                                          Icon(cat['icon'], color: const Color(0xFF225B6A)),
                                          const SizedBox(width: 8),
                                          Text(cat['label'], style: const TextStyle(color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          // Частота выполнения
                          const Text('Частота выполнения', style: TextStyle(fontSize: 17, color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Material(
                            elevation: 2,
                            shadowColor: Color(0x2252B3B6),
                            borderRadius: BorderRadius.circular(16),
                            child: DropdownButtonFormField<int>(
                              value: _targetDaysPerWeek,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6), width: 2),
                                ),
                              ),
                              style: const TextStyle(fontSize: 17, color: Color(0xFF225B6A)),
                              items: [1, 2, 3, 4, 5, 6, 7].map((days) {
                                return DropdownMenuItem(
                                  value: days,
                                  child: Text(days == 1 ? 'Ежедневно' : '$days раз в неделю'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _targetDaysPerWeek = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          // Цель/мини-задача
                          const Text('Цель / мини-задача', style: TextStyle(fontSize: 17, color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Material(
                            elevation: 2,
                            shadowColor: Color(0x2252B3B6),
                            borderRadius: BorderRadius.circular(16),
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF52B3B6), width: 2),
                                ),
                              ),
                              style: const TextStyle(fontSize: 17, color: Color(0xFF225B6A)),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 22),
                          // Напоминания
                          const Text('Напоминания', style: TextStyle(fontSize: 17, color: Color(0xFF225B6A), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Время',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF225B6A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF52B3B6)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Color(0xFF52B3B6)),
                                      const SizedBox(width: 12),
                                      Text(
                                        _reminderTime.format(context),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: const Color(0xFF225B6A),
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: _selectTime,
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF52B3B6),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: const BorderSide(color: Color(0xFF52B3B6)),
                                          ),
                                        ),
                                        child: const Text('Изменить'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Кнопка
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveHabit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF225B6A),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Сохранить',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 