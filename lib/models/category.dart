import 'package:flutter/material.dart';

class Category {
  final String label;
  final IconData icon;
  final bool isCustom;

  Category({
    required this.label,
    required this.icon,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'isCustom': isCustom,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    // Проверяем, является ли категория пользовательской
    // Если это не базовая категория, значит она пользовательская
    final baseCategories = [
      'Физическое здоровье',
      'Психическое здоровье',
      'Самообразование',
      'Творчество',
      'Навыки и карьера',
      'Быт и дисциплина',
      'Социальные действия',
      'Развлечения с пользой',
      'Другое',
      'Выберите категорию'
    ];
    
    final label = json['label'] as String;
    final isCustom = !baseCategories.contains(label);

    return Category(
      label: label,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      isCustom: isCustom,
    );
  }
} 