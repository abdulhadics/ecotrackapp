import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Model class for user data
/// Stores user profile information, points, and achievements
@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String avatar;
  
  @HiveField(4)
  final int totalPoints;
  
  @HiveField(5)
  final int currentStreak;
  
  @HiveField(6)
  final int longestStreak;
  
  @HiveField(7)
  final DateTime joinDate;
  
  @HiveField(8)
  final String ecoGoal;
  
  @HiveField(9)
  final Map<String, bool> badges;
  
  @HiveField(10)
  final bool isEmailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.joinDate,
    required this.ecoGoal,
    required this.badges,
    required this.isEmailVerified,
  });

  /// Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? joinDate,
    String? ecoGoal,
    Map<String, bool>? badges,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      joinDate: joinDate ?? this.joinDate,
      ecoGoal: ecoGoal ?? this.ecoGoal,
      badges: badges ?? this.badges,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, totalPoints: $totalPoints)';
  }
}

/// Available avatar options for users
class UserAvatars {
  static const List<String> avatars = [
    '🌱', '🌿', '🌳', '🌲', '🌴', '🌵', '🍃', '🌾',
    '🌺', '🌸', '🌼', '🌻', '🌷', '🌹', '🌻', '🌺'
  ];
}

/// Eco goals that users can choose from
class EcoGoals {
  static const List<String> goals = [
    'Make the world greener!',
    'Reduce my carbon footprint',
    'Save water every day',
    'Use less plastic',
    'Walk more, drive less',
    'Eat more plant-based foods',
    'Recycle everything possible',
    'Conserve energy at home',
  ];
}
