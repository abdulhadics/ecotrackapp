import 'package:flutter/material.dart';

/// App-wide constants and configuration
class AppConstants {
  // App Information
  static const String appName = 'EcoTrack Lite';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Sustainability Tracker';

  // Storage Keys
  static const String userKey = 'current_user';
  static const String habitsKey = 'user_habits';
  static const String badgesKey = 'user_badges';
  static const String settingsKey = 'app_settings';

  // Default Values
  static const int defaultHabitPoints = 10;
  static const int maxHabitsPerDay = 20;
  static const int streakResetDays = 1;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;

  // Spacing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];

  // Eco Tips
  static const List<String> ecoTips = [
    "Turn off lights when leaving a room to save energy!",
    "Use a reusable water bottle instead of plastic bottles.",
    "Walk or bike to nearby destinations instead of driving.",
    "Unplug electronics when not in use to save electricity.",
    "Take shorter showers to conserve water.",
    "Use cloth bags instead of plastic bags when shopping.",
    "Compost food scraps to reduce waste.",
    "Plant a tree or start a small garden at home.",
    "Use public transportation or carpool when possible.",
    "Buy local and seasonal produce to reduce carbon footprint.",
    "Repair items instead of throwing them away.",
    "Use natural light during the day instead of artificial lighting.",
    "Collect rainwater for watering plants.",
    "Choose products with minimal packaging.",
    "Turn off the tap while brushing your teeth.",
  ];

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    "Every small action counts towards a greener future! 🌱",
    "You're making a difference, one habit at a time! 💚",
    "Small steps lead to big changes! Keep going! 🌍",
    "Your eco-friendly choices inspire others! 🌟",
    "Every day is a chance to be more sustainable! 🌿",
    "You're not just saving the planet, you're saving the future! 🌎",
    "Consistency is the key to environmental change! 🔑",
    "Your efforts today will benefit generations to come! 👶",
    "Every eco-friendly choice is a vote for the planet! 🗳️",
    "You're part of the solution, not the problem! ✨",
  ];

  // Notification Settings
  static const String notificationChannelId = 'eco_reminders';
  static const String notificationChannelName = 'Eco Reminders';
  static const String notificationChannelDescription = 'Daily reminders for eco-friendly habits';

  // Default Notification Times
  static const List<int> reminderHours = [8, 12, 18]; // 8 AM, 12 PM, 6 PM
}

/// Color scheme for the app
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50); // Green
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);

  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3); // Blue
  static const Color secondaryDark = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  // Category Colors
  static const Color waterColor = Color(0xFF2196F3);
  static const Color energyColor = Color(0xFFFF9800);
  static const Color wasteColor = Color(0xFF4CAF50);
  static const Color transportColor = Color(0xFF9C27B0);
  static const Color foodColor = Color(0xFFF44336);
  static const Color generalColor = Color(0xFF607D8B);
}

/// Text styles for consistent typography
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );
}
