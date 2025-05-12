import 'package:flutter/material.dart';
import 'package:habitgo/models/habit.dart';

class CalendarWidget extends StatelessWidget {
  final Habit habit;
  final Function(DateTime) onDateTapped;

  const CalendarWidget({
    super.key,
    required this.habit,
    required this.onDateTapped,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    // TODO: Implement previous month navigation
                  },
                ),
                Text(
                  '${_getMonthName(now.month)} ${now.year}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // TODO: Implement next month navigation
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                return Center(
                  child: Text(
                    weekdays[index],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 rows * 7 days
              itemBuilder: (context, index) {
                final day = index - firstWeekday + 1;
                if (day < 1 || day > lastDayOfMonth.day) {
                  return const SizedBox();
                }

                final date = DateTime(now.year, now.month, day);
                final isCompleted = habit.isCompletedForDate(date);
                final isSelectedDay = habit.selectedWeekdays.contains(date.weekday);

                return InkWell(
                  onTap: isSelectedDay ? () => onDateTapped(date) : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : isSelectedDay
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onPrimary
                              : isSelectedDay
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[month - 1];
  }
} 