import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/providers/achievement_provider.dart';
import 'package:habitgo/models/achievement.dart';

class AchievementSystemScreen extends StatefulWidget {
  const AchievementSystemScreen({super.key});

  @override
  State<AchievementSystemScreen> createState() => _AchievementSystemScreenState();
}

class _AchievementSystemScreenState extends State<AchievementSystemScreen> {
  String _searchQuery = '';
  bool _showOnlyUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final allAchievements = userProvider.user?.getAllAchievements() ?? [];

    // Фильтрация достижений
    List<Achievement> filteredAchievements = allAchievements.where((achievement) {
      // Поиск по названию и описанию
      final matchesSearch = _searchQuery.isEmpty ||
          achievement.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          achievement.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Фильтр по статусу
      final matchesStatus = !_showOnlyUnlocked || achievement.isUnlocked;
      
      return matchesSearch && matchesStatus;
    }).toList();

    // Группировка по типам
    final groupedAchievements = <AchievementType, List<Achievement>>{};
    for (final achievement in filteredAchievements) {
      groupedAchievements.putIfAbsent(achievement.type, () => []).add(achievement);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
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
              // Заголовок и кнопка назад
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF225B6A)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Система достижений',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF225B6A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52B3B6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${userProvider.user?.unlockedAchievementsCount ?? 0}/${userProvider.user?.totalAchievementsCount ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Поиск и фильтры
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Поиск
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Поиск достижений...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF52B3B6)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF52B3B6), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Фильтр "Только разблокированные"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilterChip(
                          label: const Text('Только разблокированные'),
                          selected: _showOnlyUnlocked,
                          onSelected: (value) => setState(() => _showOnlyUnlocked = value),
                          backgroundColor: Colors.white.withOpacity(0.9),
                          selectedColor: const Color(0xFF52B3B6).withOpacity(0.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Список достижений
              Expanded(
                child: filteredAchievements.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Достижения не найдены',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Попробуйте изменить фильтры',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: groupedAchievements.length,
                        itemBuilder: (context, index) {
                          final type = groupedAchievements.keys.elementAt(index);
                          final achievements = groupedAchievements[type]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  _getTypeName(type),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF225B6A),
                                  ),
                                ),
                              ),
                              ...achievements.map((achievement) => 
                                _buildAchievementTile(context, achievement, achievementProvider)
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, Achievement achievement, AchievementProvider achievementProvider) {
    final progress = achievementProvider.getAchievementProgress(achievement.id);
    final isUnlocked = achievement.isUnlocked;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? achievement.color.withOpacity(0.1)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked 
              ? achievement.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? achievement.color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement.icon,
                  color: isUnlocked ? achievement.color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? const Color(0xFF225B6A) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? const Color(0xFF225B6A) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (isUnlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Получено ${_formatDate(achievement.unlockedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: achievement.color.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.habitCompletion:
        return 'Завершение привычек';
      case AchievementType.streakDays:
        return 'Серия дней';
      case AchievementType.totalHabits:
        return 'Количество привычек';
      case AchievementType.perfectWeek:
        return 'Идеальная неделя';
      case AchievementType.categoryMaster:
        return 'Мастер категорий';
      case AchievementType.earlyBird:
        return 'Ранняя пташка';
      case AchievementType.nightOwl:
        return 'Ночная сова';
      case AchievementType.weekendWarrior:
        return 'Воин выходных';
      case AchievementType.consistencyKing:
        return 'Король постоянства';
      case AchievementType.speedRunner:
        return 'Быстрый старт';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'сегодня';
    } else if (difference.inDays == 1) {
      return 'вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дней назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${_getWeekForm(weeks)} назад';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${_getMonthForm(months)} назад';
    }
  }

  String _getWeekForm(int weeks) {
    if (weeks == 1) return 'неделю';
    if (weeks < 5) return 'недели';
    return 'недель';
  }

  String _getMonthForm(int months) {
    if (months == 1) return 'месяц';
    if (months < 5) return 'месяца';
    return 'месяцев';
  }
} 