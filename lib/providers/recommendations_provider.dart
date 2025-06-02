import 'package:flutter/material.dart';
import 'dart:math';
import '../models/recommendation.dart';

class RecommendationsProvider with ChangeNotifier {
  List<Recommendation> _recommendations = [];
  Recommendation? _currentRecommendation;
  final Random _random = Random();

  List<Recommendation> get recommendations => _recommendations;
  Recommendation get currentRecommendation => _currentRecommendation ?? _recommendations.first;

  Future<void> loadRecommendations() async {
    _recommendations = await Recommendation.loadFromPrefs();
    
    // Выбираем случайную рекомендацию при загрузке
    if (_recommendations.isNotEmpty) {
      _currentRecommendation = _recommendations[_random.nextInt(_recommendations.length)];
    }
    
    notifyListeners();
  }

  Future<void> saveRecommendations() async {
    await Recommendation.saveToPrefs(_recommendations);
  }
} 