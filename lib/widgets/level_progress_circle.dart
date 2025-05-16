import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_provider.dart';

class LevelProgressCircle extends StatelessWidget {
  const LevelProgressCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProvider>(
      builder: (context, levelProvider, child) {
        final userLevel = levelProvider.userLevel;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: userLevel.getProgressPercentage(),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Уровень',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${userLevel.level}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userLevel.status,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${userLevel.currentXp}/${userLevel.xpToNextLevel} XP',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }
} 