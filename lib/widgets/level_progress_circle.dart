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
            const SizedBox(height: 4),
            Text(
              userLevel.status,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF52B3B6),
              ),
            ),
          ],
        );
      },
    );
  }
} 