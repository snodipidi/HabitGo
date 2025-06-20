import 'package:flutter/material.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/models/category.dart';
import 'package:habitgo/screens/category_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _selectedDeadlineTime = const TimeOfDay(hour: 23, minute: 59);
  Category _selectedCategory = Category(label: 'Выберите категорию', icon: Icons.category);
  List<int> _selectedWeekdays = [1, 3, 5]; // По умолчанию: понедельник, среда, пятница
  HabitDuration _selectedDuration = HabitDuration.easy;
  int _selectedDurationDays = 21; // По умолчанию 21 день

  final List<String> _weekdays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectDeadlineTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDeadlineTime,
    );
    if (picked != null && picked != _selectedDeadlineTime) {
      setState(() {
        _selectedDeadlineTime = picked;
      });
    }
  }

  void _selectCategory() async {
    final Category? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategorySelectionScreen(),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCategory = selected;
      });
    }
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_selectedWeekdays.contains(day)) {
        _selectedWeekdays.remove(day);
      } else {
        _selectedWeekdays.add(day);
      }
      _selectedWeekdays.sort();
    });
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.9 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF52B3B6)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Новая привычка',
                      style: TextStyle(
                        color: Color(0xFF225B6A),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.9 * 255).toInt()),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Название привычки',
                                  labelStyle: const TextStyle(color: Color(0xFF52B3B6)),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  prefixIcon: const Icon(Icons.edit, color: Color(0xFF52B3B6)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                style: const TextStyle(fontSize: 18, color: Color(0xFF225B6A)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Пожалуйста, введите название привычки';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Описание/Инструкция',
                                  labelStyle: const TextStyle(color: Color(0xFF52B3B6)),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  prefixIcon: const Icon(Icons.description, color: Color(0xFF52B3B6)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                style: const TextStyle(fontSize: 16, color: Color(0xFF225B6A)),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF52B3B6)),
                                ),
                                child: ListTile(
                                  leading: Icon(_selectedCategory.icon, color: const Color(0xFF52B3B6)),
                                  title: const Text(
                                    'Категория',
                                    style: TextStyle(color: Color(0xFF52B3B6)),
                                  ),
                                  subtitle: Text(
                                    _selectedCategory.label,
                                    style: const TextStyle(color: Color(0xFF225B6A)),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF52B3B6)),
                                  onTap: _selectCategory,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF52B3B6)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                margin: const EdgeInsets.only(bottom: 24, top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Сложность',
                                      style: TextStyle(
                                        color: Color(0xFF225B6A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: HabitDuration.values.map((duration) {
                                        final isSelected = _selectedDuration == duration;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedDuration = duration;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isSelected ? const Color(0xFF52B3B6) : Colors.white.withAlpha((0.9 * 255).toInt()),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFF52B3B6)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  duration.label,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: isSelected ? Colors.white : const Color(0xFF225B6A),
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Дни недели',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF225B6A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: List.generate(7, (index) {
                                  final day = index + 1;
                                  final isSelected = _selectedWeekdays.contains(day);
                                  return FilterChip(
                                    label: Text(
                                      _weekdays[index],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : const Color(0xFF52B3B6),
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) => _toggleWeekday(day),
                                    backgroundColor: Colors.white.withAlpha((0.9 * 255).toInt()),
                                    selectedColor: const Color(0xFF52B3B6),
                                    checkmarkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: Color(0xFF52B3B6)),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectTime,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFF52B3B6)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Начало',
                                              style: TextStyle(
                                                color: Color(0xFF52B3B6),
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedTime.format(context),
                                              style: const TextStyle(
                                                color: Color(0xFF225B6A),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectDeadlineTime,
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFF52B3B6)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Конец',
                                              style: TextStyle(
                                                color: Color(0xFF52B3B6),
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedDeadlineTime.format(context),
                                              style: const TextStyle(
                                                color: Color(0xFF225B6A),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF52B3B6)),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.calendar_today, color: Color(0xFF52B3B6)),
                                  title: const Text(
                                    'Длительность (дней)',
                                    style: TextStyle(color: Color(0xFF52B3B6)),
                                  ),
                                  subtitle: Text(
                                    '$_selectedDurationDays дней',
                                    style: const TextStyle(color: Color(0xFF225B6A)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, color: Color(0xFF52B3B6)),
                                        onPressed: _selectedDurationDays > 7
                                            ? () {
                                                setState(() {
                                                  _selectedDurationDays -= 7;
                                                });
                                              }
                                            : null,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Color(0xFF52B3B6)),
                                        onPressed: _selectedDurationDays < 84 // 12 weeks * 7 days
                                            ? () {
                                                setState(() {
                                                  _selectedDurationDays += 7;
                                                });
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              SizedBox(
                                height: 60,
                                child: Material(
                                  color: const Color(0xFF52B3B6),
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (_selectedCategory.label == 'Выберите категорию') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Пожалуйста, выберите категорию'),
                                              backgroundColor: Color(0xFF52B3B6),
                                            ),
                                          );
                                          return;
                                        }
                                        final habit = Habit(
                                          title: _titleController.text,
                                          description: _descriptionController.text,
                                          selectedWeekdays: _selectedWeekdays,
                                          reminderTime: _selectedTime,
                                          category: _selectedCategory,
                                          duration: _selectedDuration,
                                          startDate: DateTime.now(),
                                          endTime: _selectedDeadlineTime.hour >= 0 && _selectedDeadlineTime.minute >= 0
                                              ? DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                  _selectedDeadlineTime.hour,
                                                  _selectedDeadlineTime.minute,
                                                )
                                              : null,
                                          durationDays: _selectedDurationDays,
                                        );
                                        Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Создать',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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