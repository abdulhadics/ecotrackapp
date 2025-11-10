import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Settings service for managing app preferences and mode switching
/// Handles Magic Mode vs Power Mode configuration
class SettingsService extends ChangeNotifier {
  static const String _preferredModeKey = 'preferred_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _reminderHoursKey = 'reminder_hours';
  static const String _languageKey = 'language';
  static const String _magicModeSettingsKey = 'magic_mode_settings';
  static const String _powerModeSettingsKey = 'power_mode_settings';

  // Default values
  static const String _defaultMode = 'magic';
  static const bool _defaultSoundEnabled = true;
  static const bool _defaultAnimationsEnabled = true;
  static const List<int> _defaultReminderHours = [8, 12, 18];
  static const String _defaultLanguage = 'en';

  // Current settings
  String _preferredMode = _defaultMode;
  bool _soundEnabled = _defaultSoundEnabled;
  bool _animationsEnabled = _defaultAnimationsEnabled;
  List<int> _reminderHours = List.from(_defaultReminderHours);
  String _language = _defaultLanguage;
  MagicModeSettings _magicModeSettings = MagicModeSettings.defaultSettings();
  PowerModeSettings _powerModeSettings = PowerModeSettings.defaultSettings();

  // Getters
  String get preferredMode => _preferredMode;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;
  List<int> get reminderHours => List.from(_reminderHours);
  String get language => _language;
  MagicModeSettings get magicModeSettings => _magicModeSettings;
  PowerModeSettings get powerModeSettings => _powerModeSettings;
  
  // Computed properties
  bool get isMagicMode => _preferredMode == 'magic';
  bool get isPowerMode => _preferredMode == 'power';

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _preferredMode = prefs.getString(_preferredModeKey) ?? _defaultMode;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? _defaultSoundEnabled;
      _animationsEnabled = prefs.getBool(_animationsEnabledKey) ?? _defaultAnimationsEnabled;
      _language = prefs.getString(_languageKey) ?? _defaultLanguage;
      
      // Load reminder hours
      final reminderHoursString = prefs.getString(_reminderHoursKey);
      if (reminderHoursString != null) {
        _reminderHours = List<int>.from(jsonDecode(reminderHoursString));
      }
      
      // Load mode-specific settings
      await _loadMagicModeSettings(prefs);
      await _loadPowerModeSettings(prefs);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing settings: $e');
      }
    }
  }

  /// Load Magic Mode specific settings
  Future<void> _loadMagicModeSettings(SharedPreferences prefs) async {
    try {
      final settingsString = prefs.getString(_magicModeSettingsKey);
      if (settingsString != null) {
        final settingsMap = jsonDecode(settingsString) as Map<String, dynamic>;
        _magicModeSettings = MagicModeSettings.fromJson(settingsMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Magic Mode settings: $e');
      }
    }
  }

  /// Load Power Mode specific settings
  Future<void> _loadPowerModeSettings(SharedPreferences prefs) async {
    try {
      final settingsString = prefs.getString(_powerModeSettingsKey);
      if (settingsString != null) {
        final settingsMap = jsonDecode(settingsString) as Map<String, dynamic>;
        _powerModeSettings = PowerModeSettings.fromJson(settingsMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Power Mode settings: $e');
      }
    }
  }

  /// Switch between Magic Mode and Power Mode
  Future<void> switchMode(String mode) async {
    if (mode != 'magic' && mode != 'power') {
      throw ArgumentError('Mode must be either "magic" or "power"');
    }

    _preferredMode = mode;
    await _saveToPreferences();
    notifyListeners();
  }

  /// Update sound settings
  Future<void> updateSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveToPreferences();
    notifyListeners();
  }

  /// Update animation settings
  Future<void> updateAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    await _saveToPreferences();
    notifyListeners();
  }

  /// Update reminder hours
  Future<void> updateReminderHours(List<int> hours) async {
    _reminderHours = List.from(hours);
    await _saveToPreferences();
    notifyListeners();
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    _language = language;
    await _saveToPreferences();
    notifyListeners();
  }

  /// Update Magic Mode specific settings
  Future<void> updateMagicModeSettings(MagicModeSettings settings) async {
    _magicModeSettings = settings;
    await _saveMagicModeSettings();
    notifyListeners();
  }

  /// Update Power Mode specific settings
  Future<void> updatePowerModeSettings(PowerModeSettings settings) async {
    _powerModeSettings = settings;
    await _savePowerModeSettings();
    notifyListeners();
  }

  /// Save all settings to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_preferredModeKey, _preferredMode);
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
      await prefs.setBool(_animationsEnabledKey, _animationsEnabled);
      await prefs.setString(_languageKey, _language);
      await prefs.setString(_reminderHoursKey, jsonEncode(_reminderHours));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving settings: $e');
      }
    }
  }

  /// Save Magic Mode settings
  Future<void> _saveMagicModeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_magicModeSettingsKey, jsonEncode(_magicModeSettings.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving Magic Mode settings: $e');
      }
    }
  }

  /// Save Power Mode settings
  Future<void> _savePowerModeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_powerModeSettingsKey, jsonEncode(_powerModeSettings.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving Power Mode settings: $e');
      }
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _preferredMode = _defaultMode;
    _soundEnabled = _defaultSoundEnabled;
    _animationsEnabled = _defaultAnimationsEnabled;
    _reminderHours = List.from(_defaultReminderHours);
    _language = _defaultLanguage;
    _magicModeSettings = MagicModeSettings.defaultSettings();
    _powerModeSettings = PowerModeSettings.defaultSettings();
    
    await _saveToPreferences();
    await _saveMagicModeSettings();
    await _savePowerModeSettings();
    notifyListeners();
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return {
      'preferred_mode': _preferredMode,
      'sound_enabled': _soundEnabled,
      'animations_enabled': _animationsEnabled,
      'reminder_hours': _reminderHours,
      'language': _language,
      'magic_mode_settings': _magicModeSettings.toJson(),
      'power_mode_settings': _powerModeSettings.toJson(),
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      _preferredMode = settings['preferred_mode'] ?? _defaultMode;
      _soundEnabled = settings['sound_enabled'] ?? _defaultSoundEnabled;
      _animationsEnabled = settings['animations_enabled'] ?? _defaultAnimationsEnabled;
      _reminderHours = List<int>.from(settings['reminder_hours'] ?? _defaultReminderHours);
      _language = settings['language'] ?? _defaultLanguage;
      
      if (settings['magic_mode_settings'] != null) {
        _magicModeSettings = MagicModeSettings.fromJson(settings['magic_mode_settings']);
      }
      
      if (settings['power_mode_settings'] != null) {
        _powerModeSettings = PowerModeSettings.fromJson(settings['power_mode_settings']);
      }
      
      await _saveToPreferences();
      await _saveMagicModeSettings();
      await _savePowerModeSettings();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error importing settings: $e');
      }
    }
  }
}

/// Magic Mode specific settings
class MagicModeSettings {
  final String colorScheme; // 'rainbow', 'nature', 'ocean', 'sunset'
  final double animationIntensity; // 0.0 to 1.0
  final bool showSparkles;
  final bool showBouncing;
  final bool showPulsing;
  final String stickerTheme; // 'animals', 'nature', 'fantasy', 'space'
  final bool enableHapticFeedback;
  final bool enableSoundEffects;
  final List<String> favoriteStickers;
  final String backgroundMusic; // 'nature', 'ambient', 'none'

  MagicModeSettings({
    required this.colorScheme,
    required this.animationIntensity,
    required this.showSparkles,
    required this.showBouncing,
    required this.showPulsing,
    required this.stickerTheme,
    required this.enableHapticFeedback,
    required this.enableSoundEffects,
    required this.favoriteStickers,
    required this.backgroundMusic,
  });

  factory MagicModeSettings.defaultSettings() {
    return MagicModeSettings(
      colorScheme: 'nature',
      animationIntensity: 0.8,
      showSparkles: true,
      showBouncing: true,
      showPulsing: true,
      stickerTheme: 'nature',
      enableHapticFeedback: true,
      enableSoundEffects: true,
      favoriteStickers: ['🌱', '🌿', '🌳', '🦋', '🐝', '🌺', '🌸', '🌻'],
      backgroundMusic: 'nature',
    );
  }

  factory MagicModeSettings.fromJson(Map<String, dynamic> json) {
    return MagicModeSettings(
      colorScheme: json['color_scheme'] ?? 'nature',
      animationIntensity: (json['animation_intensity'] ?? 0.8).toDouble(),
      showSparkles: json['show_sparkles'] ?? true,
      showBouncing: json['show_bouncing'] ?? true,
      showPulsing: json['show_pulsing'] ?? true,
      stickerTheme: json['sticker_theme'] ?? 'nature',
      enableHapticFeedback: json['enable_haptic_feedback'] ?? true,
      enableSoundEffects: json['enable_sound_effects'] ?? true,
      favoriteStickers: List<String>.from(json['favorite_stickers'] ?? ['🌱', '🌿', '🌳', '🦋', '🐝', '🌺', '🌸', '🌻']),
      backgroundMusic: json['background_music'] ?? 'nature',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color_scheme': colorScheme,
      'animation_intensity': animationIntensity,
      'show_sparkles': showSparkles,
      'show_bouncing': showBouncing,
      'show_pulsing': showPulsing,
      'sticker_theme': stickerTheme,
      'enable_haptic_feedback': enableHapticFeedback,
      'enable_sound_effects': enableSoundEffects,
      'favorite_stickers': favoriteStickers,
      'background_music': backgroundMusic,
    };
  }

  MagicModeSettings copyWith({
    String? colorScheme,
    double? animationIntensity,
    bool? showSparkles,
    bool? showBouncing,
    bool? showPulsing,
    String? stickerTheme,
    bool? enableHapticFeedback,
    bool? enableSoundEffects,
    List<String>? favoriteStickers,
    String? backgroundMusic,
  }) {
    return MagicModeSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      showSparkles: showSparkles ?? this.showSparkles,
      showBouncing: showBouncing ?? this.showBouncing,
      showPulsing: showPulsing ?? this.showPulsing,
      stickerTheme: stickerTheme ?? this.stickerTheme,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      favoriteStickers: favoriteStickers ?? this.favoriteStickers,
      backgroundMusic: backgroundMusic ?? this.backgroundMusic,
    );
  }
}

/// Power Mode specific settings
class PowerModeSettings {
  final String colorScheme; // 'minimal', 'dark', 'light', 'high_contrast'
  final bool showDetailedStats;
  final bool showAdvancedCharts;
  final bool enableDataExport;
  final bool enableNotifications;
  final String dateFormat; // 'MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd'
  final String timeFormat; // '12h', '24h'
  final List<String> visibleCategories;
  final bool showPointsBreakdown;
  final bool enableGoalTracking;
  final int weeklyGoal;
  final int monthlyGoal;

  PowerModeSettings({
    required this.colorScheme,
    required this.showDetailedStats,
    required this.showAdvancedCharts,
    required this.enableDataExport,
    required this.enableNotifications,
    required this.dateFormat,
    required this.timeFormat,
    required this.visibleCategories,
    required this.showPointsBreakdown,
    required this.enableGoalTracking,
    required this.weeklyGoal,
    required this.monthlyGoal,
  });

  factory PowerModeSettings.defaultSettings() {
    return PowerModeSettings(
      colorScheme: 'minimal',
      showDetailedStats: true,
      showAdvancedCharts: true,
      enableDataExport: true,
      enableNotifications: true,
      dateFormat: 'MM/dd/yyyy',
      timeFormat: '24h',
      visibleCategories: ['Water Conservation', 'Energy Saving', 'Waste Reduction', 'Green Transport', 'Sustainable Food', 'General'],
      showPointsBreakdown: true,
      enableGoalTracking: true,
      weeklyGoal: 100,
      monthlyGoal: 400,
    );
  }

  factory PowerModeSettings.fromJson(Map<String, dynamic> json) {
    return PowerModeSettings(
      colorScheme: json['color_scheme'] ?? 'minimal',
      showDetailedStats: json['show_detailed_stats'] ?? true,
      showAdvancedCharts: json['show_advanced_charts'] ?? true,
      enableDataExport: json['enable_data_export'] ?? true,
      enableNotifications: json['enable_notifications'] ?? true,
      dateFormat: json['date_format'] ?? 'MM/dd/yyyy',
      timeFormat: json['time_format'] ?? '24h',
      visibleCategories: List<String>.from(json['visible_categories'] ?? ['Water Conservation', 'Energy Saving', 'Waste Reduction', 'Green Transport', 'Sustainable Food', 'General']),
      showPointsBreakdown: json['show_points_breakdown'] ?? true,
      enableGoalTracking: json['enable_goal_tracking'] ?? true,
      weeklyGoal: json['weekly_goal'] ?? 100,
      monthlyGoal: json['monthly_goal'] ?? 400,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color_scheme': colorScheme,
      'show_detailed_stats': showDetailedStats,
      'show_advanced_charts': showAdvancedCharts,
      'enable_data_export': enableDataExport,
      'enable_notifications': enableNotifications,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'visible_categories': visibleCategories,
      'show_points_breakdown': showPointsBreakdown,
      'enable_goal_tracking': enableGoalTracking,
      'weekly_goal': weeklyGoal,
      'monthly_goal': monthlyGoal,
    };
  }

  PowerModeSettings copyWith({
    String? colorScheme,
    bool? showDetailedStats,
    bool? showAdvancedCharts,
    bool? enableDataExport,
    bool? enableNotifications,
    String? dateFormat,
    String? timeFormat,
    List<String>? visibleCategories,
    bool? showPointsBreakdown,
    bool? enableGoalTracking,
    int? weeklyGoal,
    int? monthlyGoal,
  }) {
    return PowerModeSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      showDetailedStats: showDetailedStats ?? this.showDetailedStats,
      showAdvancedCharts: showAdvancedCharts ?? this.showAdvancedCharts,
      enableDataExport: enableDataExport ?? this.enableDataExport,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      visibleCategories: visibleCategories ?? this.visibleCategories,
      showPointsBreakdown: showPointsBreakdown ?? this.showPointsBreakdown,
      enableGoalTracking: enableGoalTracking ?? this.enableGoalTracking,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
    );
  }
}
