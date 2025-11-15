import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weqacalc/models/achievement.dart';

class AchievementService extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<Achievement> _unlockedAchievements = [];

  List<Achievement> get unlockedAchievements => _unlockedAchievements;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAchievements();
  }

  void _loadAchievements() {
    final json = _prefs.getString('achievements');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _unlockedAchievements = list
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (_unlockedAchievements.any((a) => a.id == achievementId)) {
      return; // Already unlocked
    }

    final achievement = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    final unlockedAchievement = Achievement(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      icon: achievement.icon,
      category: achievement.category,
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    );

    _unlockedAchievements.add(unlockedAchievement);
    await _saveAchievements();
    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    final json = jsonEncode(
      _unlockedAchievements.map((a) => a.toJson()).toList(),
    );
    await _prefs.setString('achievements', json);
  }

  bool isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements.any((a) => a.id == achievementId);
  }

  int get totalUnlocked => _unlockedAchievements.length;
}
