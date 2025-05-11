import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Recommendation {
  static const String _recommendationsKey = 'recommendations';
  static const int _currentDataVersion = 1;

  final String text;
  final String category;
  final int _dataVersion;

  Recommendation({
    required this.text,
    required this.category,
    int? dataVersion,
  }) : _dataVersion = dataVersion ?? _currentDataVersion;

  Map<String, dynamic> toJson() {
    return {
      'version': _dataVersion,
      'text': text,
      'category': category,
    };
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 0;
    
    if (version < _currentDataVersion) {
      json['version'] = _currentDataVersion;
    }

    return Recommendation(
      dataVersion: json['version'] as int,
      text: json['text'] as String,
      category: json['category'] as String,
    );
  }

  static List<Recommendation> getDefaultRecommendations() {
    return [
      Recommendation(
        text: 'Пейте больше воды, она помогает жить',
        category: 'health',
      ),
      Recommendation(
        text: 'Сделайте небольшую разминку каждые 30 минут',
        category: 'health',
      ),
      Recommendation(
        text: 'Выделите 5 минут на глубокое дыхание',
        category: 'wellness',
      ),
      Recommendation(
        text: 'Съешьте фрукт вместо сладкого',
        category: 'nutrition',
      ),
      Recommendation(
        text: 'Прогуляйтесь на свежем воздухе',
        category: 'activity',
      ),
    ];
  }

  static Future<List<Recommendation>> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recommendationsJson = prefs.getString(_recommendationsKey);
      
      if (recommendationsJson == null) {
        return getDefaultRecommendations();
      }
      
      final List<dynamic> recommendationsList = json.decode(recommendationsJson);
      return recommendationsList
          .map((json) => Recommendation.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      return getDefaultRecommendations();
    }
  }

  static Future<void> saveToPrefs(List<Recommendation> recommendations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recommendationsJson = json.encode(
        recommendations.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_recommendationsKey, recommendationsJson);
    } catch (e) {
      debugPrint('Error saving recommendations: $e');
    }
  }
} 