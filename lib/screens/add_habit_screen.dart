import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/models/habit.dart';
import 'package:habitgo/providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final _habitDescriptionController = TextEditingController();

  @override
  void dispose() {
    _habitNameController.dispose();
    _habitDescriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        title: _habitNameController.text,
        description: _habitDescriptionController.text,
        targetDaysPerWeek: 7,
        reminderTime: const TimeOfDay(hour: 9, minute: 0),
      );
      Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1FFFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF52B3B6)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Новая привычка',
          style: TextStyle(
            color: Color(0xFF52B3B6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _habitNameController,
                decoration: InputDecoration(
                  labelText: 'Название привычки',
                  labelStyle: const TextStyle(color: Color(0xFF52B3B6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название привычки';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _habitDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: const TextStyle(color: Color(0xFF52B3B6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF52B3B6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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