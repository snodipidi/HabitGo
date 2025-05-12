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
    return Category(
      label: json['label'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
} 