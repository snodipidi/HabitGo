import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/models/category.dart';
import 'package:habitgo/providers/habit_provider.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late Category _category;
  late HabitDuration _duration;
  late TimeOfDay _reminderTime;
  late TimeOfDay _endTime;
  bool _hasEndTime = false;

  @override
  void initState() {
    super.initState();
    _title = widget.habit?.title ?? '';
    _description = widget.habit?.description ?? '';
    _category = widget.habit?.category ?? Category(label: 'Выберите категорию', icon: Icons.category);
    _duration = widget.habit?.duration ?? HabitDuration.easy;
    _reminderTime = widget.habit?.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.habit?.endTime != null 
        ? TimeOfDay.fromDateTime(widget.habit!.endTime!)
        : const TimeOfDay(hour: 23, minute: 59);
    _hasEndTime = widget.habit?.endTime != null;
  }

  Future<void> _selectTime(BuildContext context, bool isReminderTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isReminderTime ? _reminderTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isReminderTime) {
          _reminderTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      DateTime? endDateTime;
      if (_hasEndTime) {
        endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _endTime.hour,
          _endTime.minute,
        );
      }

      final habit = Habit(
        id: widget.habit?.id,
        title: _title,
        description: _description,
        category: _category,
        duration: _duration,
        reminderTime: _reminderTime,
        startDate: now,
        endTime: endDateTime,
      );

      if (widget.habit == null) {
        context.read<HabitProvider>().addHabit(habit);
      } else {
        context.read<HabitProvider>().updateHabit(habit);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Новая привычка' : 'Редактировать привычку'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                return null;
              },
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) => _description = value ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: Category(label: 'Физическое здоровье', icon: Icons.fitness_center),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Физическое здоровье'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Психическое здоровье', icon: Icons.self_improvement),
                  child: Row(
                    children: [
                      const Icon(Icons.self_improvement, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Психическое здоровье'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Самообразование', icon: Icons.school),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Самообразование'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Творчество', icon: Icons.palette),
                  child: Row(
                    children: [
                      const Icon(Icons.palette, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Творчество'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Навыки и карьера', icon: Icons.work),
                  child: Row(
                    children: [
                      const Icon(Icons.work, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Навыки и карьера'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Быт и дисциплина', icon: Icons.home),
                  child: Row(
                    children: [
                      const Icon(Icons.home, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Быт и дисциплина'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Социальные действия', icon: Icons.people),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Социальные действия'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: Category(label: 'Развлечения с пользой', icon: Icons.sports_esports),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_esports, color: Color(0xFF52B3B6)),
                      const SizedBox(width: 8),
                      const Text('Развлечения с пользой'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitDuration>(
              value: _duration,
              decoration: const InputDecoration(
                labelText: 'Периодичность',
                border: OutlineInputBorder(),
              ),
              items: HabitDuration.values.map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text(duration.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _duration = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Время напоминания'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context, true),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Установить время окончания'),
              value: _hasEndTime,
              onChanged: (value) {
                setState(() => _hasEndTime = value);
              },
            ),
            if (_hasEndTime) ...[
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Время окончания'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52B3B6),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.habit == null ? 'Создать' : 'Сохранить',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 