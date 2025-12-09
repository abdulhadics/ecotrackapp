import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart' as badge_model;

/// Hive service for local data management
/// Handles user data, habits, and badges using Hive local storage
class HiveService extends ChangeNotifier {
  late Box<User> _userBox;
  late Box<Habit> _habitBox;
  late Box<badge_model.Badge> _badgeBox;
  
  User? _currentUser;
  List<Habit> _habits = [];
  List<badge_model.Badge> _badges = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  List<Habit> get habits => _habits;
  List<badge_model.Badge> get badges => _badges;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize Hive boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      // Use WidgetsBinding to defer notifyListeners call
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Register adapters
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(HabitAdapter());
      Hive.registerAdapter(badge_model.BadgeAdapter());

      // Open boxes
      _userBox = await Hive.openBox<User>('users');
      _habitBox = await Hive.openBox<Habit>('habits');
      _badgeBox = await Hive.openBox<badge_model.Badge>('badges');

      // PRINT THE PATH FOR THE USER
      if (kIsWeb) {
        debugPrint('🌐 RUNNING ON WEB: Hive uses IndexedDB (Browser Storage).');
        debugPrint('   To view data: Open Chrome DevTools (F12) -> Application -> IndexedDB');
      } else {
        debugPrint('📦 HIVE DATABASE LOCATION: ${_userBox.path ?? "Unknown (In Memory?)"}');
      }

      // Load data
      await _loadUserData();
      await _loadHabits();
      await _loadBadges();

      _isInitialized = true;
    } catch (e) {
      _showError('Failed to initialize app: $e');
    } finally {
      _isLoading = false;
      // Use WidgetsBinding to defer notifyListeners call
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Load user data from Hive
  Future<void> _loadUserData() async {
    try {
      if (_userBox.isNotEmpty) {
        _currentUser = _userBox.getAt(0);
      } else {
        // Create default user if none exists
        await _createDefaultUser();
      }
    } catch (e) {
      _showError('Failed to load user data: $e');
    }
  }

  /// Create a default user
  Future<void> _createDefaultUser() async {
    final defaultUser = User(
      id: 'default_user',
      name: 'Eco Warrior',
      email: 'user@ecotrack.com',
      avatar: '🌱',
      totalPoints: 0,
      currentStreak: 0,
      longestStreak: 0,
      joinDate: DateTime.now(),
      ecoGoal: 'Make the world greener!',
      badges: {},
      isDarkMode: false,
    );

    await _userBox.add(defaultUser);
    _currentUser = defaultUser;
  }

  /// Load habits from Hive
  Future<void> _loadHabits() async {
    try {
      _habits = _habitBox.values.toList();
      _habits.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    } catch (e) {
      _showError('Failed to load habits: $e');
    }
  }

  /// Load badges from Hive
  Future<void> _loadBadges() async {
    try {
      if (_badgeBox.isEmpty) {
        // Initialize with default badges
        for (badge_model.Badge badge in badge_model.BadgeDefinitions.allBadges) {
          await _badgeBox.add(badge);
        }
      }
      _badges = _badgeBox.values.toList();
    } catch (e) {
      _showError('Failed to load badges: $e');
    }
  }

  /// Update user profile
  Future<bool> updateUser(User updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update in Hive
      await _userBox.putAt(0, updatedUser);
      _currentUser = updatedUser;

      _showSuccess('Profile updated successfully!');
      return true;
    } catch (e) {
      _showError('Failed to update profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new habit
  Future<bool> addHabit(Habit habit) async {
    try {
      // Check if a habit with the same ID already exists
      bool habitExists = _habits.any((h) => h.id == habit.id);
      if (habitExists) {
        _showError('Habit already exists!');
        return false;
      }
      
      await _habitBox.add(habit);
      await _loadHabits();
      notifyListeners();
      _showSuccess('Habit added successfully!');
      return true;
    } catch (e) {
      _showError('Failed to add habit: $e');
      return false;
    }
  }

  /// Update a habit
  Future<bool> updateHabit(Habit habit) async {
    try {
      // Find the habit by its unique ID in the Hive box
      int index = -1;
      for (int i = 0; i < _habitBox.length; i++) {
        Habit? existingHabit = _habitBox.getAt(i);
        if (existingHabit != null && existingHabit.id == habit.id) {
          index = i;
          break;
        }
      }
      
      if (index != -1) {
        await _habitBox.putAt(index, habit);
        await _loadHabits();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _showError('Failed to update habit: $e');
      return false;
    }
  }

  /// Delete a habit
  Future<bool> deleteHabit(Habit habit) async {
    try {
      await habit.delete();
      await _loadHabits();
      _showSuccess('Habit deleted successfully!');
      return true;
    } catch (e) {
      _showError('Failed to delete habit: $e');
      return false;
    }
  }

  /// Mark habit as completed and update points
  Future<bool> completeHabit(Habit habit) async {
    if (_currentUser == null) return false;

    try {
      // Double-check if habit is already completed to prevent duplicates
      if (habit.isCompleted) {
        _showSuccess('Habit already completed!');
        return true;
      }

      // Update habit as completed
      Habit updatedHabit = habit.copyWith(isCompleted: true);
      bool success = await updateHabit(updatedHabit);
      
      if (success) {
        // Update user points
        int newPoints = _currentUser!.totalPoints + habit.points;
        await _updateUserPoints(newPoints);

        _showSuccess('Great job! +${habit.points} eco points!');
        return true;
      }
      return false;
    } catch (e) {
      _showError('Failed to complete habit: $e');
      return false;
    }
  }

  /// Update user points and check for new badges
  Future<void> _updateUserPoints(int newPoints) async {
    if (_currentUser == null) return;

    try {
      User updatedUser = _currentUser!.copyWith(totalPoints: newPoints);
      await updateUser(updatedUser);

      // Check for new badges
      List<badge_model.Badge> newBadges = badge_model.BadgeDefinitions.checkForNewBadges(
        newPoints,
        _badges,
      );

      if (newBadges.isNotEmpty) {
        await _unlockBadges(newBadges);
      }
    } catch (e) {
      _showError('Failed to update points: $e');
    }
  }

  /// Unlock new badges
  Future<void> _unlockBadges(List<badge_model.Badge> newBadges) async {
    if (_currentUser == null) return;

    try {
      Map<String, bool> updatedBadges = Map.from(_currentUser!.badges);
      
      for (badge_model.Badge badge in newBadges) {
        updatedBadges[badge.id] = true;
        
        // Update badge in Hive
        int index = _badges.indexWhere((b) => b.id == badge.id);
        if (index != -1) {
          badge_model.Badge updatedBadge = badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
          await _badgeBox.putAt(index, updatedBadge);
        }
      }

      // Update user badges
      User updatedUser = _currentUser!.copyWith(badges: updatedBadges);
      await updateUser(updatedUser);

      // Reload badges
      await _loadBadges();

      // Show celebration for new badges
      for (badge_model.Badge badge in newBadges) {
        _showSuccess('🎉 New badge unlocked: ${badge.name}!');
      }
    } catch (e) {
      _showError('Failed to unlock badges: $e');
    }
  }

  /// Get habits for a specific date
  List<Habit> getHabitsForDate(DateTime date) {
    return _habits.where((habit) {
      return habit.date.year == date.year &&
             habit.date.month == date.month &&
             habit.date.day == date.day;
    }).toList();
  }

  /// Get today's habits
  List<Habit> getTodaysHabits() {
    return getHabitsForDate(DateTime.now());
  }

  /// Get completed habits count for today
  int getTodaysCompletedHabits() {
    return getTodaysHabits().where((habit) => habit.isCompleted).length;
  }

  /// Get total points for today
  int getTodaysPoints() {
    return getTodaysHabits()
        .where((habit) => habit.isCompleted)
        .fold(0, (sum, habit) => sum + habit.points);
  }

  /// Get weekly habits for chart
  List<Map<String, dynamic>> getWeeklyHabits() {
    List<Map<String, dynamic>> weeklyData = [];
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      List<Habit> dayHabits = getHabitsForDate(date);
      int completedCount = dayHabits.where((h) => h.isCompleted).length;
      
      weeklyData.add({
        'date': date,
        'completed': completedCount,
        'total': dayHabits.length,
      });
    }
    
    return weeklyData;
  }

  /// Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  /// Get unlocked badges
  List<badge_model.Badge> getUnlockedBadges() {
    return _badges.where((badge) => badge.isUnlocked).toList();
  }

  /// Get locked badges
  List<badge_model.Badge> getLockedBadges() {
    return _badges.where((badge) => !badge.isUnlocked).toList();
  }

  /// Get badges by category
  List<badge_model.Badge> getBadgesByCategory(String category) {
    return _badges.where((badge) => badge.category == category).toList();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_currentUser == null) return;

    User updatedUser = _currentUser!.copyWith(isDarkMode: !_currentUser!.isDarkMode);
    await updateUser(updatedUser);
  }

  /// Show success message
  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Show error message
  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Close all boxes (call this when app is disposed)
  @override
  Future<void> dispose() async {
    await _userBox.close();
    await _habitBox.close();
    await _badgeBox.close();
    super.dispose();
  }
}
