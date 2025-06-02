import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendations_provider.dart';

class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, child) {
        if (provider.recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        final recommendation = provider.currentRecommendation;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForCategory(recommendation.category),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Рекомендация',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'health':
        return Icons.favorite_outline;
      case 'wellness':
        return Icons.spa_outlined;
      case 'nutrition':
        return Icons.restaurant_outlined;
      case 'activity':
        return Icons.directions_walk_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
} 