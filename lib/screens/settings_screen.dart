import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/widgets/level_progress_circle.dart';
import 'package:habitgo/services/auth_service.dart';

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
                  // КРАСНАЯ ПЛАШКА ЕСЛИ НЕ ВЫПОЛНЕН ВХОД (СРАЗУ ПОД ЗАГОЛОВКОМ)
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
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF52B3B6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              levelProvider.userLevel.level.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                levelProvider.userLevel.status,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF225B6A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${levelProvider.userLevel.currentXp} XP / ${levelProvider.userLevel.xpToNextLevel} XP до уровня ${levelProvider.userLevel.level + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF52B3B6),
                                ),
                              ),
                            ],
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
                      icon: const Icon(Icons.g_mobiledata, color: Color(0xFF52B3B6)),
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
                          leading: const Icon(Icons.notifications_outlined, color: Color(0xFF225B6A)),
                          title: const Text('Уведомления'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.color_lens_outlined, color: Color(0xFF225B6A)),
                          title: const Text('Тема приложения'),
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

  Widget _buildLevelInfo(String title, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF225B6A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNameEditDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(
      text: Provider.of<UserProvider>(context, listen: false).user?.name ?? '',
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ваше имя',
            hintText: 'Введите новое имя',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Provider.of<UserProvider>(context, listen: false)
                    .setUserName(nameController.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
} 