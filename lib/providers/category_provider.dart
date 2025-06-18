import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:habitgo/models/category.dart';
import 'package:habitgo/providers/habit_provider.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [
    Category(label: 'Физическое здоровье', icon: Icons.fitness_center),
    Category(label: 'Психическое здоровье', icon: Icons.self_improvement),
    Category(label: 'Самообразование', icon: Icons.school),
    Category(label: 'Творчество', icon: Icons.brush),
    Category(label: 'Навыки и карьера', icon: Icons.work_outline),
    Category(label: 'Быт и дисциплина', icon: Icons.home),
    Category(label: 'Социальные действия', icon: Icons.people_outline),
    Category(label: 'Развлечения с пользой', icon: Icons.extension),
  ];

  HabitProvider? _habitProvider;

  List<Category> get categories => [..._categories];
  
  // Получаем только базовые категории
  List<Category> get baseCategories => _categories.where((cat) => !cat.isCustom).toList();
  
  // Получаем только пользовательские категории
  List<Category> get customCategories => _categories.where((cat) => cat.isCustom).toList();

  CategoryProvider() {
    _loadCategories();
  }

  void setHabitProvider(HabitProvider habitProvider) {
    _habitProvider = habitProvider;
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
    if (!_categories.any((cat) => cat.label == category.label)) {
      _categories.add(category);
      _saveCategories();
      notifyListeners();
    }
  }

  void removeCategory(Category category) {
    if (category.isCustom) {
      _categories.removeWhere((cat) => cat.label == category.label);
      _saveCategories();
      notifyListeners();
    }
  }

  // Метод для проверки, используется ли категория в привычках
  bool isCategoryInUse(String categoryLabel) {
    if (_habitProvider == null) return false;
    return _habitProvider!.isCategoryInUse(categoryLabel);
  }

  // Метод для очистки неиспользуемых пользовательских категорий
  void cleanupUnusedCategories() {
    final unusedCategories = customCategories.where((category) => !isCategoryInUse(category.label));
    for (var category in unusedCategories) {
      removeCategory(category);
    }
  }
} 