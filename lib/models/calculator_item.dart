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
  final List<String> tags;

  CalculatorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.category,
    required this.route,
    this.tags = const [],
  });
}

class Categories {
  static const loans = 'Loans';
  static const investments = 'Investments';
  static const deposits = 'Deposits & Savings';
  static const government = 'Government Schemes';
  static const retirement = 'Retirement & FIRE';

  static const List<String> all = [
    loans,
    investments,
    deposits,
    government,
    retirement,
  ];
}
