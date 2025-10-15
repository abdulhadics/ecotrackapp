import 'package:hive/hive.dart';

part 'badge_model.g.dart';

/// Model class for achievement badges
/// Represents different milestones and achievements users can unlock
@HiveType(typeId: 2)
class Badge extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String icon;
  
  @HiveField(4)
  final int requiredPoints;
  
  @HiveField(5)
  final String category;
  
  @HiveField(6)
  final bool isUnlocked;
  
  @HiveField(7)
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredPoints,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// Create a copy of the badge with updated fields
  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? requiredPoints,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, isUnlocked: $isUnlocked)';
  }
}

/// Predefined badges that users can earn
class BadgeDefinitions {
  static List<Badge> allBadges = [
    // Starter badges
    Badge(
      id: 'green_starter',
      name: 'Green Starter',
      description: 'Complete your first eco habit',
      icon: '🌱',
      requiredPoints: 10,
      category: 'Starter',
      isUnlocked: false,
    ),
    Badge(
      id: 'first_week',
      name: 'First Week',
      description: 'Complete habits for 7 days straight',
      icon: '📅',
      requiredPoints: 70,
      category: 'Streak',
      isUnlocked: false,
    ),
    
    // Point milestones
    Badge(
      id: 'eco_enthusiast',
      name: 'Eco Enthusiast',
      description: 'Earn 100 eco points',
      icon: '🌟',
      requiredPoints: 100,
      category: 'Points',
      isUnlocked: false,
    ),
    Badge(
      id: 'eco_hero',
      name: 'Eco Hero',
      description: 'Earn 500 eco points',
      icon: '🦸‍♀️',
      requiredPoints: 500,
      category: 'Points',
      isUnlocked: false,
    ),
    Badge(
      id: 'eco_legend',
      name: 'Eco Legend',
      description: 'Earn 1000 eco points',
      icon: '👑',
      requiredPoints: 1000,
      category: 'Points',
      isUnlocked: false,
    ),
    
    // Streak badges
    Badge(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '⚔️',
      requiredPoints: 70,
      category: 'Streak',
      isUnlocked: false,
    ),
    Badge(
      id: 'month_master',
      name: 'Month Master',
      description: 'Maintain a 30-day streak',
      icon: '🏆',
      requiredPoints: 300,
      category: 'Streak',
      isUnlocked: false,
    ),
    
    // Category badges
    Badge(
      id: 'water_saver',
      name: 'Water Saver',
      description: 'Complete 10 water conservation habits',
      icon: '💧',
      requiredPoints: 100,
      category: 'Water',
      isUnlocked: false,
    ),
    Badge(
      id: 'energy_efficient',
      name: 'Energy Efficient',
      description: 'Complete 10 energy saving habits',
      icon: '⚡',
      requiredPoints: 100,
      category: 'Energy',
      isUnlocked: false,
    ),
    Badge(
      id: 'waste_warrior',
      name: 'Waste Warrior',
      description: 'Complete 10 waste reduction habits',
      icon: '♻️',
      requiredPoints: 100,
      category: 'Waste',
      isUnlocked: false,
    ),
  ];

  /// Get badges by category
  static List<Badge> getBadgesByCategory(String category) {
    return allBadges.where((badge) => badge.category == category).toList();
  }

  /// Get unlocked badges
  static List<Badge> getUnlockedBadges(List<Badge> userBadges) {
    return userBadges.where((badge) => badge.isUnlocked).toList();
  }

  /// Get locked badges
  static List<Badge> getLockedBadges(List<Badge> userBadges) {
    return userBadges.where((badge) => !badge.isUnlocked).toList();
  }

  /// Check if user should unlock any new badges based on points
  static List<Badge> checkForNewBadges(int totalPoints, List<Badge> currentBadges) {
    List<Badge> newBadges = [];
    
    for (Badge badge in allBadges) {
      if (totalPoints >= badge.requiredPoints) {
        // Check if user already has this badge
        bool alreadyHasBadge = currentBadges.any((userBadge) => userBadge.id == badge.id);
        if (!alreadyHasBadge) {
          newBadges.add(badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now()));
        }
      }
    }
    
    return newBadges;
  }
}
