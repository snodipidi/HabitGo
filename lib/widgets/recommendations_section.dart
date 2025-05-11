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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Рекомендации',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.currentRecommendation.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        );
      },
    );
  }
} 