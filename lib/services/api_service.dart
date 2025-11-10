import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Robust API service for EcoTrack Lite
/// Handles all backend communication with proper error handling and logging
class ApiService {
  static const String _baseUrl = 'https://api.ecotrack-lite.com/v1';
  static const Duration _timeout = Duration(seconds: 30);
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// HTTP client with timeout configuration
  final http.Client _client = http.Client();

  /// Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'EcoTrack-Lite/1.0.0',
  };

  /// Get authentication token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Set authentication token
  Future<void> _setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Generic HTTP request handler with error handling
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Add authentication header if required
      final headers = Map<String, String>.from(_headers);
      if (requiresAuth) {
        final token = await _getAuthToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      // Build URL with query parameters
      Uri url = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      // Log request for debugging
      if (kDebugMode) {
        print('🌐 API Request: $method $url');
        if (body != null) {
          print('📤 Request Body: ${jsonEncode(body)}');
        }
      }

      // Make HTTP request
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(url, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(url, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: headers).timeout(_timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // Log response for debugging
      if (kDebugMode) {
        print('📥 API Response: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      // Handle response
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } on FormatException {
      return ApiResponse.error('Invalid response format from server.');
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Handle HTTP response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (fromJson != null) {
          final result = fromJson(data);
          return ApiResponse.success(result);
        } else {
          return ApiResponse.success(data as T);
        }
      } catch (e) {
        return ApiResponse.error('Failed to parse response: $e');
      }
    } else {
      return _handleErrorResponse(response);
    }
  }

  /// Handle error responses
  ApiResponse<T> _handleErrorResponse<T>(http.Response response) {
    final statusCode = response.statusCode;
    
    try {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Unknown error occurred';
      
      switch (statusCode) {
        case 400:
          return ApiResponse.error('Bad request: $message');
        case 401:
          return ApiResponse.error('Unauthorized: Please log in again');
        case 403:
          return ApiResponse.error('Forbidden: $message');
        case 404:
          return ApiResponse.error('Resource not found: $message');
        case 429:
          return ApiResponse.error('Too many requests: Please try again later');
        case 500:
          return ApiResponse.error('Server error: Please try again later');
        default:
          return ApiResponse.error('HTTP $statusCode: $message');
      }
    } catch (e) {
      return ApiResponse.error('HTTP $statusCode: ${response.body}');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Register a new user
  Future<ApiResponse<UserData>> registerUser({
    required String name,
    required String email,
    required String password,
    String? avatar,
    String ecoGoal = 'Make the world greener!',
  }) async {
    return _makeRequest<UserData>(
      'POST',
      '/users/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'avatar': avatar ?? '🌱',
        'eco_goal': ecoGoal,
      },
      requiresAuth: false,
      fromJson: (data) => UserData.fromJson(data),
    );
  }

  /// Login user
  Future<ApiResponse<AuthData>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest<AuthData>(
      'POST',
      '/users/login',
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
      fromJson: (data) => AuthData.fromJson(data),
    );

    // Store auth token if login successful
    if (response.isSuccess && response.data != null) {
      await _setAuthToken(response.data!.token);
    }

    return response;
  }

  /// Get current user profile
  Future<ApiResponse<UserData>> getCurrentUser() async {
    return _makeRequest<UserData>(
      'GET',
      '/users/me',
      fromJson: (data) => UserData.fromJson(data),
    );
  }

  /// Update user profile
  Future<ApiResponse<UserData>> updateUserProfile({
    String? name,
    String? avatar,
    String? ecoGoal,
    bool? isDarkMode,
    String? preferredMode, // 'magic' or 'power'
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) body['avatar'] = avatar;
    if (ecoGoal != null) body['eco_goal'] = ecoGoal;
    if (isDarkMode != null) body['is_dark_mode'] = isDarkMode;
    if (preferredMode != null) body['preferred_mode'] = preferredMode;

    return _makeRequest<UserData>(
      'PUT',
      '/users/me',
      body: body,
      fromJson: (data) => UserData.fromJson(data),
    );
  }

  // ==================== HABIT MANAGEMENT ====================

  /// Get user habits
  Future<ApiResponse<List<HabitData>>> getHabits({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (category != null) queryParams['category'] = category;

    return _makeRequest<List<HabitData>>(
      'GET',
      '/habits',
      queryParams: queryParams,
      fromJson: (data) => (data['habits'] as List)
          .map((habit) => HabitData.fromJson(habit))
          .toList(),
    );
  }

  /// Create a new habit
  Future<ApiResponse<HabitData>> createHabit({
    required String title,
    required String description,
    required String category,
    required int points,
    required DateTime date,
  }) async {
    return _makeRequest<HabitData>(
      'POST',
      '/habits',
      body: {
        'title': title,
        'description': description,
        'category': category,
        'points': points,
        'date': date.toIso8601String(),
      },
      fromJson: (data) => HabitData.fromJson(data),
    );
  }

  /// Update a habit
  Future<ApiResponse<HabitData>> updateHabit({
    required String habitId,
    String? title,
    String? description,
    String? category,
    int? points,
    bool? isCompleted,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (points != null) body['points'] = points;
    if (isCompleted != null) body['is_completed'] = isCompleted;

    return _makeRequest<HabitData>(
      'PUT',
      '/habits/$habitId',
      body: body,
      fromJson: (data) => HabitData.fromJson(data),
    );
  }

  /// Delete a habit
  Future<ApiResponse<void>> deleteHabit(String habitId) async {
    return _makeRequest<void>(
      'DELETE',
      '/habits/$habitId',
    );
  }

  /// Complete a habit
  Future<ApiResponse<HabitCompletionData>> completeHabit(String habitId) async {
    return _makeRequest<HabitCompletionData>(
      'POST',
      '/habits/$habitId/complete',
      fromJson: (data) => HabitCompletionData.fromJson(data),
    );
  }

  // ==================== ANALYTICS & INSIGHTS ====================

  /// Get user analytics
  Future<ApiResponse<AnalyticsData>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    return _makeRequest<AnalyticsData>(
      'GET',
      '/analytics',
      queryParams: queryParams,
      fromJson: (data) => AnalyticsData.fromJson(data),
    );
  }

  /// Get weekly progress
  Future<ApiResponse<List<WeeklyProgressData>>> getWeeklyProgress() async {
    return _makeRequest<List<WeeklyProgressData>>(
      'GET',
      '/analytics/weekly',
      fromJson: (data) => (data['weekly_progress'] as List)
          .map((progress) => WeeklyProgressData.fromJson(progress))
          .toList(),
    );
  }

  // ==================== BADGES & ACHIEVEMENTS ====================

  /// Get user badges
  Future<ApiResponse<List<BadgeData>>> getBadges() async {
    return _makeRequest<List<BadgeData>>(
      'GET',
      '/badges',
      fromJson: (data) => (data['badges'] as List)
          .map((badge) => BadgeData.fromJson(badge))
          .toList(),
    );
  }

  /// Unlock a badge
  Future<ApiResponse<BadgeData>> unlockBadge(String badgeId) async {
    return _makeRequest<BadgeData>(
      'POST',
      '/badges/$badgeId/unlock',
      fromJson: (data) => BadgeData.fromJson(data),
    );
  }

  // ==================== SETTINGS & PREFERENCES ====================

  /// Get user settings
  Future<ApiResponse<UserSettings>> getSettings() async {
    return _makeRequest<UserSettings>(
      'GET',
      '/settings',
      fromJson: (data) => UserSettings.fromJson(data),
    );
  }

  /// Update user settings
  Future<ApiResponse<UserSettings>> updateSettings({
    String? preferredMode,
    bool? soundEnabled,
    bool? animationsEnabled,
    List<int>? reminderHours,
    String? language,
  }) async {
    final body = <String, dynamic>{};
    if (preferredMode != null) body['preferred_mode'] = preferredMode;
    if (soundEnabled != null) body['sound_enabled'] = soundEnabled;
    if (animationsEnabled != null) body['animations_enabled'] = animationsEnabled;
    if (reminderHours != null) body['reminder_hours'] = reminderHours;
    if (language != null) body['language'] = language;

    return _makeRequest<UserSettings>(
      'PUT',
      '/settings',
      body: body,
      fromJson: (data) => UserSettings.fromJson(data),
    );
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// ==================== DATA MODELS ====================

/// User data model
class UserData {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime joinDate;
  final String ecoGoal;
  final String preferredMode; // 'magic' or 'power'
  final bool isDarkMode;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.joinDate,
    required this.ecoGoal,
    required this.preferredMode,
    required this.isDarkMode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '🌱',
      totalPoints: json['total_points'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      joinDate: DateTime.parse(json['join_date']),
      ecoGoal: json['eco_goal'] ?? 'Make the world greener!',
      preferredMode: json['preferred_mode'] ?? 'magic',
      isDarkMode: json['is_dark_mode'] ?? false,
    );
  }
}

/// Authentication data model
class AuthData {
  final String token;
  final UserData user;

  AuthData({
    required this.token,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: UserData.fromJson(json['user']),
    );
  }
}

/// Habit data model
class HabitData {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final DateTime date;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.date,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitData.fromJson(Map<String, dynamic> json) {
    return HabitData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      points: json['points'],
      date: DateTime.parse(json['date']),
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Habit completion data model
class HabitCompletionData {
  final HabitData habit;
  final int pointsEarned;
  final int newTotalPoints;
  final List<BadgeData> newBadges;

  HabitCompletionData({
    required this.habit,
    required this.pointsEarned,
    required this.newTotalPoints,
    required this.newBadges,
  });

  factory HabitCompletionData.fromJson(Map<String, dynamic> json) {
    return HabitCompletionData(
      habit: HabitData.fromJson(json['habit']),
      pointsEarned: json['points_earned'],
      newTotalPoints: json['new_total_points'],
      newBadges: (json['new_badges'] as List)
          .map((badge) => BadgeData.fromJson(badge))
          .toList(),
    );
  }
}

/// Analytics data model
class AnalyticsData {
  final int totalHabits;
  final int completedHabits;
  final int totalPoints;
  final int currentStreak;
  final Map<String, int> categoryBreakdown;
  final List<WeeklyProgressData> weeklyProgress;

  AnalyticsData({
    required this.totalHabits,
    required this.completedHabits,
    required this.totalPoints,
    required this.currentStreak,
    required this.categoryBreakdown,
    required this.weeklyProgress,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalHabits: json['total_habits'],
      completedHabits: json['completed_habits'],
      totalPoints: json['total_points'],
      currentStreak: json['current_streak'],
      categoryBreakdown: Map<String, int>.from(json['category_breakdown']),
      weeklyProgress: (json['weekly_progress'] as List)
          .map((progress) => WeeklyProgressData.fromJson(progress))
          .toList(),
    );
  }
}

/// Weekly progress data model
class WeeklyProgressData {
  final DateTime date;
  final int completedHabits;
  final int totalHabits;
  final int pointsEarned;

  WeeklyProgressData({
    required this.date,
    required this.completedHabits,
    required this.totalHabits,
    required this.pointsEarned,
  });

  factory WeeklyProgressData.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressData(
      date: DateTime.parse(json['date']),
      completedHabits: json['completed_habits'],
      totalHabits: json['total_habits'],
      pointsEarned: json['points_earned'],
    );
  }
}

/// Badge data model
class BadgeData {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int requiredPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  BadgeData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requiredPoints,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory BadgeData.fromJson(Map<String, dynamic> json) {
    return BadgeData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      requiredPoints: json['required_points'],
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at']) 
          : null,
    );
  }
}

/// User settings model
class UserSettings {
  final String preferredMode; // 'magic' or 'power'
  final bool soundEnabled;
  final bool animationsEnabled;
  final List<int> reminderHours;
  final String language;

  UserSettings({
    required this.preferredMode,
    required this.soundEnabled,
    required this.animationsEnabled,
    required this.reminderHours,
    required this.language,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      preferredMode: json['preferred_mode'] ?? 'magic',
      soundEnabled: json['sound_enabled'] ?? true,
      animationsEnabled: json['animations_enabled'] ?? true,
      reminderHours: List<int>.from(json['reminder_hours'] ?? [8, 12, 18]),
      language: json['language'] ?? 'en',
    );
  }
}
