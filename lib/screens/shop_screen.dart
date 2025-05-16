import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/user_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final coins = userProvider.user?.habitCoins ?? 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF225B6A)),
        title: const Text(
          'Магазин',
          style: TextStyle(
            color: Color(0xFF225B6A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1FFFC), Color(0xFF52B3B6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, size: 60, color: Color(0xFFFFC107)),
                const SizedBox(height: 16),
                Text(
                  'Ваши монеты',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF225B6A),
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: coins),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutExpo,
                  key: ValueKey(coins),
                  builder: (context, value, child) => Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF52B3B6),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'В будущем здесь появятся товары и бонусы!',
                  style: TextStyle(fontSize: 16, color: Color(0xFF225B6A)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 