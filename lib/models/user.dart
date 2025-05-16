import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class User {
  static const String _userKey = 'user_data';
  static const int _currentDataVersion = 1;

  String name;
  List<String> achievements;
  int streakDays;
  int habitCoins;
  int _dataVersion;

  User({
    required this.name,
    this.achievements = const [],
    this.streakDays = 0,
    this.habitCoins = 0,
    int? dataVersion,
  }) : _dataVersion = dataVersion ?? _currentDataVersion;

  Map<String, dynamic> toJson() {
    return {
      'version': _dataVersion,
      'name': name,
      'achievements': achievements,
      'streakDays': streakDays,
      'habitCoins': habitCoins,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 0;
    
    // Handle data migration if needed
    if (version < _currentDataVersion) {
      // Add migration logic here when data structure changes
      // For now, just update the version
      json['version'] = _currentDataVersion;
    }

    return User(
      dataVersion: json['version'] as int,
      name: json['name'] as String,
      achievements: List<String>.from(json['achievements'] ?? []),
      streakDays: json['streakDays'] as int? ?? 0,
      habitCoins: json['habitCoins'] as int? ?? 0,
    );
  }

  static Future<User?> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // Log error and return null
      debugPrint('Error loading user data: $e');
      return null;
    }
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      // Log error but don't throw
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
} 