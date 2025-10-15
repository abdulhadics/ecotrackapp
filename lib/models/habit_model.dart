import 'package:hive/hive.dart';

part 'habit_model.g.dart';

/// Model class for eco-friendly habits
/// This represents a single habit that users can track daily
@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final int points;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final bool isCompleted;
  
  @HiveField(7)
  final String userId;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.date,
    required this.isCompleted,
    required this.userId,
  });

  /// Create a copy of the habit with updated fields
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    DateTime? date,
    bool? isCompleted,
    String? userId,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, category: $category, points: $points, isCompleted: $isCompleted)';
  }
}

/// Categories for different types of eco-friendly habits
class HabitCategory {
  static const String water = 'Water Conservation';
  static const String energy = 'Energy Saving';
  static const String waste = 'Waste Reduction';
  static const String transport = 'Green Transport';
  static const String food = 'Sustainable Food';
  static const String general = 'General';

  static const List<String> all = [
    water,
    energy,
    waste,
    transport,
    food,
    general,
  ];

  static const Map<String, String> icons = {
    water: '💧',
    energy: '⚡',
    waste: '♻️',
    transport: '🚶',
    food: '🥗',
    general: '🌱',
  };
}
