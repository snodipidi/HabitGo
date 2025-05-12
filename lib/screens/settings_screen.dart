import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUserName(userCredential.user?.displayName ?? 'Пользователь');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успешный вход через Google')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка входа через Google')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUserName('Пользователь');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выход выполнен успешно')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при выходе')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authService = _authService;
    final isSignedIn = authService.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1FFFC),
              Color(0xFF00A0A6),
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
                      'Настройки',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // User profile section
                    if (isSignedIn) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: authService.currentUser?.photoURL != null
                                  ? NetworkImage(authService.currentUser!.photoURL!)
                                  : null,
                              child: authService.currentUser?.photoURL == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authService.currentUser?.displayName ?? 'Пользователь',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF225B6A),
                                    ),
                                  ),
                                  Text(
                                    authService.currentUser?.email ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Authentication buttons
                    if (!isSignedIn) ...[
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Image.asset('assets/icons/google.png', height: 24),
                        label: const Text('Войти через Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF225B6A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Other settings
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
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
                            onTap: () async {
                              final newName = await showDialog<String>(
                                context: context,
                                builder: (context) => _NameEditDialog(
                                  initialName: userProvider.userName,
                                ),
                              );
                              if (newName != null) {
                                await userProvider.setUserName(newName);
                              }
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.notifications_outlined, color: Color(0xFF225B6A)),
                            title: const Text('Уведомления'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement notifications settings
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.color_lens_outlined, color: Color(0xFF225B6A)),
                            title: const Text('Тема приложения'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement theme settings
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameEditDialog extends StatefulWidget {
  final String initialName;

  const _NameEditDialog({required this.initialName});

  @override
  State<_NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<_NameEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить имя'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Введите ваше имя',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
} 