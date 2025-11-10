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

  // Enhanced Earth Theme Stickers and Emojis
  static const List<String> earthStickers = [
    // Plants & Nature
    '🌱', '🌿', '🍃', '🌾', '🌳', '🌲', '🌴', '🌵', '🌺', '🌸', '🌼', '🌻',
    '🌹', '🌷', '🌻', '🌺', '🌼', '🌸', '🌿', '🍀', '🌱', '🌾', '🌳', '🌲',
    '🌴', '🌵', '🌰', '🌰', '🌰', '🌰', '🌰', '🌰', '🌰', '🌰', '🌰', '🌰',
    
    // Earth & Environment
    '🌍', '🌎', '🌏', '🌊', '🏔️', '⛰️', '🌋', '🏞️', '🌅', '🌄', '🌆', '🌇',
    '🌃', '🌌', '🌠', '⭐', '🌟', '💫', '✨', '🌙', '☀️', '🌈', '☁️', '⛅',
    '🌤️', '🌦️', '🌧️', '⛈️', '🌩️', '❄️', '☃️', '⛄', '🌨️', '🌩️', '🌪️', '🌫️',
    
    // Animals & Wildlife
    '🦋', '🐛', '🐝', '🐞', '🦗', '🕷️', '🦎', '🐸', '🐢', '🐍', '🦜', '🦅',
    '🐦', '🐤', '🐣', '🐥', '🦆', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝',
    '🐛', '🦋', '🐌', '🦟', '🦗', '🕷️', '🦂', '🐢', '🐍', '🦎', '🐸', '🐊',
    
    // Food & Agriculture
    '🍄', '🌰', '🌽', '🥕', '🥬', '🥒', '🌶️', '🫑', '🌽', '🍅', '🍆', '🥔',
    '🥜', '🌰', '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏',
    '🍐', '🍑', '🍒', '🍓', '🫐', '🥝', '🍅', '🥥', '🥑', '🍆', '🥔', '🥕',
    
    // Eco-Friendly Items
    '♻️', '🌿', '🌱', '🌾', '🌳', '🌲', '🌴', '🌵', '🌺', '🌸', '🌼', '🌻',
    '💧', '⚡', '🔥', '🌬️', '🌊', '🏔️', '⛰️', '🌋', '🏞️', '🌅', '🌄', '🌆',
    '🌇', '🌃', '🌌', '🌠', '⭐', '🌟', '💫', '✨', '🌙', '☀️', '🌈', '☁️',
    
    // Celebration & Achievement
    '🎉', '🎊', '🎈', '🎁', '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '⭐', '🌟',
    '💫', '✨', '🎯', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭',
    '🎪', '🎨', '🎭', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭', '🎪', '🎨', '🎭'
  ];

  // Eco Tips
  static const List<String> ecoTips = [
    "Turn off lights when leaving a room to save energy! 🌿",
    "Use a reusable water bottle instead of plastic bottles. 💧",
    "Walk or bike to nearby destinations instead of driving. 🚶‍♀️",
    "Unplug electronics when not in use to save electricity. ⚡",
    "Take shorter showers to conserve water. 🚿",
    "Use cloth bags instead of plastic bags when shopping. 🛍️",
    "Compost food scraps to reduce waste. ♻️",
    "Plant a tree or start a small garden at home. 🌱",
    "Use public transportation or carpool when possible. 🚌",
    "Buy local and seasonal produce to reduce carbon footprint. 🥗",
    "Repair items instead of throwing them away. 🔧",
    "Use natural light during the day instead of artificial lighting. ☀️",
    "Collect rainwater for watering plants. 🌧️",
    "Choose products with minimal packaging. 📦",
    "Turn off the tap while brushing your teeth. 🦷",
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
    "Nature thanks you for every green choice! 🍃",
    "Your sustainable habits are blooming beautifully! 🌸",
    "Keep growing your eco-friendly garden of habits! 🌻",
    "You're planting seeds of change for tomorrow! 🌱",
    "Every leaf of change makes the forest stronger! 🌳",
  ];

  // Notification Settings
  static const String notificationChannelId = 'eco_reminders';
  static const String notificationChannelName = 'Eco Reminders';
  static const String notificationChannelDescription = 'Daily reminders for eco-friendly habits';

  // Default Notification Times
  static const List<int> reminderHours = [8, 12, 18]; // 8 AM, 12 PM, 6 PM
}

/// Color scheme for the app - Modern Glowy Earth Theme
class AppColors {
  // Primary Colors - Balanced Earth Green
  static const Color primary = Color(0xFF2E7D32); // Deep Forest Green
  static const Color primaryDark = Color(0xFF1B5E20); // Darker Forest
  static const Color primaryLight = Color(0xFF4CAF50); // Bright Leaf Green

  // Secondary Colors - Warm Earth Tones
  static const Color secondary = Color(0xFF8D6E63); // Earth Brown
  static const Color secondaryDark = Color(0xFF5D4037); // Dark Earth
  static const Color secondaryLight = Color(0xFFA1887F); // Light Earth

  // Accent Colors - Modern Earth Palette
  static const Color accent = Color(0xFF66BB6A); // Fresh Leaf
  static const Color accentDark = Color(0xFF388E3C); // Mature Leaf
  static const Color accentLight = Color(0xFF81C784); // Young Leaf

  // Modern Earth Theme Colors
  static const Color sunsetOrange = Color(0xFFFF7043); // Warm Sunset
  static const Color skyBlue = Color(0xFF42A5F5); // Clear Sky
  static const Color lavender = Color(0xFFAB47BC); // Evening Lavender
  static const Color amber = Color(0xFFFFA726); // Golden Amber
  static const Color coral = Color(0xFFFF5722); // Warm Coral
  static const Color mint = Color(0xFF4DB6AC); // Fresh Mint

  // Glow Effects Colors
  static const Color glowGreen = Color(0xFF81C784); // Soft Green Glow
  static const Color glowBlue = Color(0xFF90CAF9); // Soft Blue Glow
  static const Color glowOrange = Color(0xFFFFB74D); // Warm Orange Glow
  static const Color glowPurple = Color(0xFFCE93D8); // Soft Purple Glow
  static const Color glowAmber = Color(0xFFFFCC80); // Golden Glow

  // Status Colors - Nature Inspired
  static const Color success = Color(0xFF2E7D32); // Forest Green
  static const Color warning = Color(0xFFF57C00); // Autumn Orange
  static const Color error = Color(0xFFD32F2F); // Earth Red
  static const Color info = Color(0xFF1976D2); // Sky Blue

  // Neutral Colors - Earth Tones
  static const Color background = Color(0xFFF1F8E9); // Light Sage
  static const Color surface = Color(0xFFF9FBE7); // Cream Green
  static const Color onBackground = Color(0xFF1B5E20); // Dark Forest
  static const Color onSurface = Color(0xFF2E7D32); // Forest Green

  // Dark Theme Colors - Night Forest
  static const Color darkBackground = Color(0xFF0D1B0D); // Deep Forest Night
  static const Color darkSurface = Color(0xFF1A2E1A); // Dark Forest
  static const Color darkOnBackground = Color(0xFF81C784); // Light Leaf
  static const Color darkOnSurface = Color(0xFFA5D6A7); // Pale Leaf

  // Enhanced Category Colors - Modern Earth Palette
  static const Color waterColor = Color(0xFF42A5F5); // Sky Blue
  static const Color energyColor = Color(0xFFFF7043); // Sunset Orange
  static const Color wasteColor = Color(0xFF2E7D32); // Forest Green
  static const Color transportColor = Color(0xFF8D6E63); // Earth Brown
  static const Color foodColor = Color(0xFF66BB6A); // Fresh Green
  static const Color generalColor = Color(0xFF558B2F); // Olive Green

  // Additional Earth Theme Colors
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color mossGreen = Color(0xFF689F38);
  static const Color sageGreen = Color(0xFF9CCC65);
  static const Color earthBrown = Color(0xFF8D6E63);
  static const Color barkBrown = Color(0xFF5D4037);
  static const Color soilBrown = Color(0xFF3E2723);
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
