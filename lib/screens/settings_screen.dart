import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/widgets/level_progress_circle.dart';
import 'package:habitgo/services/auth_service.dart';
import 'package:habitgo/screens/shop_screen.dart';
import 'package:habitgo/widgets/statistics_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levelProvider = Provider.of<LevelProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userLevel = levelProvider.userLevel;
    final authService = AuthService();

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Стрелка назад и заголовок
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF225B6A)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Настройки',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF225B6A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // КРАСНАЯ ПЛАШКА ЕСЛИ НЕ ВЫПОЛНЕН ВХОД
                  if (!userProvider.isGoogleSignedIn) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD6D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Вход не выполнен',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // БЕЛАЯ КАРТОЧКА С УРОВНЕМ
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Consumer<LevelProvider>(
                          builder: (context, levelProvider, child) {
                            final userLevel = levelProvider.userLevel;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        value: userLevel.getProgressPercentage(),
                                        strokeWidth: 3,
                                        backgroundColor: const Color(0xFFE1FFFC),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52B3B6)),
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE1FFFC),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF52B3B6), width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          userLevel.level.toString(),
                                          style: const TextStyle(
                                            color: Color(0xFF225B6A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Consumer<LevelProvider>(
                            builder: (context, levelProvider, child) {
                              final userLevel = levelProvider.userLevel;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userLevel.status,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF225B6A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${userLevel.currentXp} XP / ${userLevel.xpToNextLevel} XP до уровня ${userLevel.level + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF52B3B6),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // КНОПКА GOOGLE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await authService.signInWithGoogle();
                        if (result != null && context.mounted) {
                          userProvider.updateUserName(result.user?.displayName ?? 'Пользователь');
                        }
                      },
                      icon: Image.asset('assets/icons/google.png', height: 24),
                      label: const Text('Войти через Google', style: TextStyle(color: Color(0xFF225B6A))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // СТАТИСТИКА
                  const StatisticsCard(),
                  const SizedBox(height: 24),
                  // ОТДЕЛЬНАЯ КАРТОЧКА НАСТРОЕК
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFF225B6A)),
                          title: const Text('Изменить имя'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showNameEditDialog(context),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.store, color: Color(0xFF225B6A)),
                          title: const Text('Магазин'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ShopScreen()),
                            );
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined, color: Color(0xFF225B6A)),
                          title: const Text('Уведомления'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Достижения
                  const Text(
                    'Достижения',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF225B6A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userProvider.user?.achievements.isEmpty ?? true)
                          const Center(
                            child: Text(
                              'Пока нет достижений',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          ...userProvider.user!.achievements.map((achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events, color: Color(0xFF52B3B6)),
                                const SizedBox(width: 8),
                                Text(
                                  achievement,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF225B6A),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNameEditDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(
      text: Provider.of<UserProvider>(context, listen: false).user?.name ?? '',
    );

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Изменить имя',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF225B6A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Введите новое имя',
                  hintStyle: const TextStyle(
                    color: Color(0xFF52B3B6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE1FFFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF52B3B6),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF225B6A),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF52B3B6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        Provider.of<UserProvider>(context, listen: false)
                            .updateUserName(nameController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52B3B6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 