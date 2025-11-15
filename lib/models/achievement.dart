class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji
  final String category; // 'fire', 'emi', 'sip', 'investment'
  final bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'category': category,
    'isUnlocked': isUnlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  static Achievement fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    icon: json['icon'],
    category: json['category'],
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedDate: json['unlockedDate'] != null
        ? DateTime.parse(json['unlockedDate'])
        : null,
  );
}

// Predefined achievements
final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_calculator',
    title: 'Financial Explorer',
    description: 'Used your first calculator',
    icon: '🔍',
    category: 'general',
  ),
  Achievement(
    id: 'fire_goal_reached',
    title: 'FIRE Dreamer',
    description: 'Set your FIRE goal',
    icon: '🔥',
    category: 'fire',
  ),
  Achievement(
    id: 'crore_milestone',
    title: 'Crorepati in Sight',
    description: 'Your wealth goal exceeds ₹1 Crore',
    icon: '💰',
    category: 'investment',
  ),
  Achievement(
    id: 'emi_optimizer',
    title: 'EMI Optimizer',
    description: 'Explored loan prepayment options',
    icon: '📊',
    category: 'emi',
  ),
  Achievement(
    id: 'sip_champion',
    title: 'SIP Champion',
    description: 'Created a consistent SIP strategy',
    icon: '📈',
    category: 'sip',
  ),
  Achievement(
    id: 'early_retirement',
    title: 'Early Retiree',
    description: 'FIRE goal is before age 45',
    icon: '🏖️',
    category: 'fire',
  ),
  Achievement(
    id: 'high_saver',
    title: 'High Saver',
    description: 'Monthly savings exceed ₹50K',
    icon: '💎',
    category: 'investment',
  ),
  Achievement(
    id: 'wealth_milestone',
    title: 'Wealth Builder',
    description: 'Multiple calculators explored',
    icon: '🏆',
    category: 'general',
  ),
];
