import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class Recommendation {
  final String text;

  Recommendation({required this.text});

  Map<String, dynamic> toJson() => {'text': text};

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(text: json['text']);
  }
}

class RecommendationsProvider with ChangeNotifier {
  List<Recommendation> _recommendations = [];
  Recommendation? _currentRecommendation;
  final Random _random = Random();

  List<Recommendation> get recommendations => _recommendations;
  Recommendation get currentRecommendation => _currentRecommendation ?? _recommendations.first;

  Future<void> loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final recommendationsJson = prefs.getString('recommendations');
    
    if (recommendationsJson != null) {
      final List<dynamic> decoded = json.decode(recommendationsJson);
      _recommendations = decoded.map((item) => Recommendation.fromJson(item)).toList();
    } else {
      _recommendations = [
        Recommendation(text: 'Пейте больше воды, она помогает жить'),
        Recommendation(text: 'Делайте небольшую разминку каждые 30 минут'),
        Recommendation(text: 'Не забывайте про осанку во время работы'),
        Recommendation(text: 'Съешьте что-нибудь полезное'),
        Recommendation(text: 'Сделайте перерыв и прогуляйтесь'),
      ];
      await saveRecommendations();
    }

    // Выбираем случайную рекомендацию при загрузке
    if (_recommendations.isNotEmpty) {
      _currentRecommendation = _recommendations[_random.nextInt(_recommendations.length)];
    }
    
    notifyListeners();
  }

  Future<void> saveRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final recommendationsJson = json.encode(_recommendations.map((r) => r.toJson()).toList());
    await prefs.setString('recommendations', recommendationsJson);
  }
} 