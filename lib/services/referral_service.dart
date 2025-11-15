import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReferralReward {
  final String id;
  final String title;
  final String description;
  final int requiredReferrals;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  ReferralReward({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredReferrals,
    required this.isUnlocked,
    this.unlockedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'requiredReferrals': requiredReferrals,
    'isUnlocked': isUnlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  factory ReferralReward.fromJson(Map<String, dynamic> json) => ReferralReward(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    requiredReferrals: json['requiredReferrals'],
    isUnlocked: json['isUnlocked'],
    unlockedDate: json['unlockedDate'] != null
        ? DateTime.parse(json['unlockedDate'])
        : null,
  );
}

class ReferralService {
  static const String _referralCountKey = 'referral_count';
  static const String _referralRewardsKey = 'referral_rewards';
  static const String _referralCodeKey = 'referral_code';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initializeReferralRewards();
  }

  void _initializeReferralRewards() {
    if (_prefs.containsKey(_referralRewardsKey)) {
      return;
    }

    final rewards = [
      ReferralReward(
        id: 'referral_1',
        title: '1st Referral',
        description: 'Unlock ad-free experience',
        requiredReferrals: 1,
        isUnlocked: false,
      ),
      ReferralReward(
        id: 'referral_5',
        title: '5 Referrals',
        description: 'Premium calculator features',
        requiredReferrals: 5,
        isUnlocked: false,
      ),
      ReferralReward(
        id: 'referral_10',
        title: '10 Referrals',
        description: 'Export results to PDF',
        requiredReferrals: 10,
        isUnlocked: false,
      ),
      ReferralReward(
        id: 'referral_25',
        title: '25 Referrals',
        description: 'Lifetime premium access',
        requiredReferrals: 25,
        isUnlocked: false,
      ),
    ];

    _saveRewards(rewards);
  }

  String _generateReferralCode() {
    if (_prefs.containsKey(_referralCodeKey)) {
      return _prefs.getString(_referralCodeKey) ?? '';
    }

    // Generate a unique referral code based on timestamp and random
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final code = 'WQ${timestamp.toString().substring(8)}';
    _prefs.setString(_referralCodeKey, code);
    return code;
  }

  String getReferralCode() {
    return _generateReferralCode();
  }

  int getReferralCount() {
    return _prefs.getInt(_referralCountKey) ?? 0;
  }

  Future<void> addReferral() async {
    final currentCount = getReferralCount();
    await _prefs.setInt(_referralCountKey, currentCount + 1);
    _checkAndUnlockRewards();
  }

  Future<void> addMultipleReferrals(int count) async {
    final currentCount = getReferralCount();
    await _prefs.setInt(_referralCountKey, currentCount + count);
    _checkAndUnlockRewards();
  }

  List<ReferralReward> getAllRewards() {
    final json = _prefs.getString(_referralRewardsKey);
    if (json == null) return [];

    final decoded = jsonDecode(json) as List;
    return decoded
        .map((r) => ReferralReward.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  void _checkAndUnlockRewards() {
    final currentCount = getReferralCount();
    final rewards = getAllRewards();
    bool updated = false;

    for (var i = 0; i < rewards.length; i++) {
      if (!rewards[i].isUnlocked &&
          currentCount >= rewards[i].requiredReferrals) {
        rewards[i] = ReferralReward(
          id: rewards[i].id,
          title: rewards[i].title,
          description: rewards[i].description,
          requiredReferrals: rewards[i].requiredReferrals,
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        );
        updated = true;
      }
    }

    if (updated) {
      _saveRewards(rewards);
    }
  }

  void _saveRewards(List<ReferralReward> rewards) {
    final json = jsonEncode(rewards.map((r) => r.toJson()).toList());
    _prefs.setString(_referralRewardsKey, json);
  }

  int getRemainingReferralsForNextReward() {
    final currentCount = getReferralCount();
    final rewards = getAllRewards();

    for (var reward in rewards) {
      if (!reward.isUnlocked) {
        return (reward.requiredReferrals - currentCount).clamp(
          0,
          reward.requiredReferrals,
        );
      }
    }

    return 0; // All rewards unlocked
  }

  Future<void> reset() async {
    await _prefs.remove(_referralCountKey);
    await _prefs.remove(_referralRewardsKey);
    await _prefs.remove(_referralCodeKey);
    _initializeReferralRewards();
  }
}
