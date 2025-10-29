import 'package:flutter/material.dart';

class CalculatorCategory {
  final String name;
  final IconData icon;

  CalculatorCategory({required this.name, required this.icon});
}

class CalculatorItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String category;
  final Widget route;

  CalculatorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.category,
    required this.route,
  });
}
