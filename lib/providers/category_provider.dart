import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:habitgo/models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [
    Category(label: 'Чтение', icon: Icons.book),
    Category(label: 'Спорт', icon: Icons.fitness_center),
    Category(label: 'Музыка', icon: Icons.music_note),
    Category(label: 'Медитация', icon: Icons.self_improvement),
    Category(label: 'Учёба', icon: Icons.school),
    Category(label: 'Другое', icon: Icons.more_horiz),
  ];

  List<Category> get categories => [..._categories];

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList('categories');
    
    if (categoriesJson != null) {
      _categories = categoriesJson
          .map((json) => Category.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = _categories
        .map((category) => jsonEncode(category.toJson()))
        .toList();
    await prefs.setStringList('categories', categoriesJson);
  }

  void addCategory(Category category) {
    // Find the index of "Другое" category
    final otherIndex = _categories.indexWhere((cat) => cat.label == 'Другое');
    // Insert new category before "Другое"
    _categories.insert(otherIndex, category);
    _saveCategories();
    notifyListeners();
  }

  void removeCategory(Category category) {
    if (category.isCustom) {
      _categories.removeWhere((cat) => cat.label == category.label);
      _saveCategories();
      notifyListeners();
    }
  }
} 