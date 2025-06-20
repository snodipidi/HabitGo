import 'package:flutter/material.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/models/category.dart';
import 'package:habitgo/screens/category_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TimeOfDay _selectedTime;
  late TimeOfDay _selectedDeadlineTime;
  late Category _selectedCategory;
  late List<int> _selectedWeekdays;
  late HabitDuration _selectedDuration;
  late int _selectedDurationDays;

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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _selectedTime = widget.habit.reminderTime;
    _selectedDeadlineTime = widget.habit.endTime != null 
        ? TimeOfDay.fromDateTime(widget.habit.endTime!)
        : const TimeOfDay(hour: 23, minute: 59);
    _selectedCategory = widget.habit.category;
    _selectedWeekdays = List.from(widget.habit.selectedWeekdays);
    _selectedDuration = widget.habit.duration;
    _selectedDurationDays = widget.habit.durationDays;
  }

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
                      'Редактировать привычку',
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
                                  labelText: 'Описание/инструкция',
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
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF52B3B6)),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Текущий прогресс',
                                          style: TextStyle(
                                            color: Color(0xFF52B3B6),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${widget.habit.completedDates.length}/${widget.habit.durationDays} дней',
                                          style: const TextStyle(
                                            color: Color(0xFF225B6A),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: widget.habit.completedDates.length / widget.habit.durationDays,
                                        backgroundColor: const Color(0xFFE0E0E0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52B3B6)),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(widget.habit.completedDates.length / widget.habit.durationDays * 100).toInt()}% выполнено',
                                      style: const TextStyle(
                                        color: Color(0xFF225B6A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
                                        final habit = Habit(
                                          id: widget.habit.id,
                                          title: _titleController.text,
                                          description: _descriptionController.text,
                                          completedDates: widget.habit.completedDates,
                                          selectedWeekdays: _selectedWeekdays,
                                          reminderTime: _selectedTime,
                                          category: _selectedCategory,
                                          duration: _selectedDuration,
                                          deadline: widget.habit.deadline,
                                          startDate: widget.habit.startDate,
                                          endTime: DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            _selectedDeadlineTime.hour,
                                            _selectedDeadlineTime.minute,
                                          ),
                                          createdAt: widget.habit.createdAt,
                                          durationDays: _selectedDurationDays,
                                          xpPerCompletion: widget.habit.xpPerCompletion,
                                        );
                                        Provider.of<HabitProvider>(context, listen: false).updateHabit(habit);
                                        Navigator.pop(context, habit);
                                      }
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Сохранить',
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