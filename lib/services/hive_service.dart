import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart' as badge_model;
import '../widgets/magic_mode_widgets.dart';

/// Hive service for local data management
/// Handles user data, habits, and badges using Hive local storage
class HiveService extends ChangeNotifier {
  late Box<User> _userBox;
  late Box<Habit> _habitBox;
  late Box<badge_model.Badge> _badgeBox;

  final List<String> _wittyRevokeComments = [
    "Oops! You deleted that habit and now your score is crying. 😢 This badge is going back to the eco-vault until you earn it back!",
    "The planet is slightly more disappointed now. 🌍 Badge revoked! Time to pick up the pace!",
    "Wait, did you just delete your progress? That badge was allergic to laziness anyway. 🤧 Gone!",
    "Recalculating... and... poof! 🪄 Your badge has vanished. Maybe try a 'Don't delete habits' habit?",
  ];

  final List<String> _celebratoryAchieveComments = [
    "You're a planet-saving legend! 🌍 This badge belongs in your trophy cabinet. Keep that momentum going!",
    "Eco-Magic at work! ✨ You've just unlocked a new piece of history. The Earth is high-fiving you right now!",
    "Look at you go! 🚀 Another milestone crushed. You're making the world a better place, one habit at a time!",
    "BOOM! 💥 New badge alert! You're officially a force of nature. What's next on your green list?",
  ];

  // EmailJS Constants (To be updated by user)
  final String _emailServiceId = 'service_vn9iw5l';
  final String _emailTemplateId = 'template_p5fo1op';
  final String _emailPublicKey = 'S5TzlRF0HG-EcFcwx';
  final String _emailPrivateKey = ''; // Provide this if using Strict Mode

  
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
      isEmailVerified: false,
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
      } else {
        // Sync missing badges
        final existingIds = _badgeBox.values.map((b) => b.id).toSet();
        for (badge_model.Badge badge in badge_model.BadgeDefinitions.allBadges) {
          if (!existingIds.contains(badge.id)) {
            await _badgeBox.add(badge);
            debugPrint('➕ Added new badge to storage: ${badge.name}');
          }
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

  /// Delete a habit with context for potential badge revocation dialogs
  Future<bool> deleteHabit(Habit habit, [BuildContext? context]) async {
    try {
      bool wasCompleted = habit.isCompleted;
      int habitPoints = habit.points;
      
      await habit.delete();
      await _loadHabits();
      
      if (wasCompleted && _currentUser != null) {
        int newPoints = _currentUser!.totalPoints - habitPoints;
        if (newPoints < 0) newPoints = 0;
        await _updateUserPoints(newPoints, context);
      }
      
      _showSuccess('Habit deleted successfully!');
      return true;
    } catch (e) {
      _showError('Failed to delete habit: $e');
      return false;
    }
  }

  /// Mark habit as completed and update points
  Future<bool> completeHabit(Habit habit, [BuildContext? context]) async {
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
        await _updateUserPoints(newPoints, context);

        _showSuccess('Great job! +${habit.points} eco points!');
        return true;
      }
      return false;
    } catch (e) {
      _showError('Failed to complete habit: $e');
      return false;
    }
  }

  /// Update user points and check for new/revoked badges
  Future<void> _updateUserPoints(int newPoints, [BuildContext? context]) async {
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
        await _unlockBadges(newBadges, context);
      }
      
      // Check for revoked badges
      List<badge_model.Badge> revokedBadges = badge_model.BadgeDefinitions.checkForRevokedBadges(
        newPoints,
        _badges,
      );
      
      if (revokedBadges.isNotEmpty) {
        await _revokeBadges(revokedBadges, context);
      }
    } catch (e) {
      _showError('Failed to update points: $e');
    }
  }

  /// Unlock new badges
  Future<void> _unlockBadges(List<badge_model.Badge> newBadges, [BuildContext? context]) async {
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

        // Show achievement dialog if context is available
        if (context != null) {
          final celebratoryMessage = _celebratoryAchieveComments[math.Random().nextInt(_celebratoryAchieveComments.length)];
          showDialog(
            context: context,
            builder: (context) => BadgeAchievedDialog(
              badge: badge,
              celebratoryMessage: celebratoryMessage,
            ),
          );
        }
      }

      // Update user badges
      User updatedUser = _currentUser!.copyWith(badges: updatedBadges);
      await updateUser(updatedUser);

      // Reload badges
      await _loadBadges();

      // Show toast as backup or for non-UI contexts
      for (badge_model.Badge badge in newBadges) {
        if (context == null) {
          _showSuccess('🎉 New badge unlocked: ${badge.name}!');
        }
      }
    } catch (e) {
      _showError('Failed to unlock badges: $e');
    }
  }

  /// Revoke badges
  Future<void> _revokeBadges(List<badge_model.Badge> revokedBadges, [BuildContext? context]) async {
    if (_currentUser == null) return;

    try {
      Map<String, bool> updatedBadges = Map.from(_currentUser!.badges);
      
      for (badge_model.Badge badge in revokedBadges) {
        updatedBadges[badge.id] = false;
        
        // Update badge in Hive
        int index = _badges.indexWhere((b) => b.id == badge.id);
        if (index != -1) {
          badge_model.Badge updatedBadge = badge.copyWith(isUnlocked: false, unlockedAt: null);
          await _badgeBox.putAt(index, updatedBadge);
        }
        
        // Show witty dialog if context is available
        if (context != null) {
          final wittyComment = _wittyRevokeComments[math.Random().nextInt(_wittyRevokeComments.length)];
          showDialog(
            context: context,
            builder: (context) => BadgeRevokedDialog(
              badge: badge,
              wittyComment: wittyComment,
            ),
          );
        }
      }

      // Update user badges
      User updatedUser = _currentUser!.copyWith(badges: updatedBadges);
      await updateUser(updatedUser);
      
      // Reload badges
      await _loadBadges();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error revoking badges: $e');
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

  /// Set email as verified
  Future<void> setEmailVerified() async {
    if (_currentUser == null) return;
    User updatedUser = _currentUser!.copyWith(isEmailVerified: true);
    await updateUser(updatedUser);
    _showSuccess('Email verified successfully! 🎉');
  }

  /// Send verification OTP using EmailJS
  Future<String> sendVerificationOTP() async {
    final random = math.Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    final userEmail = _currentUser?.email ?? '';

    if (userEmail.isEmpty) {
      _showError('No email found for user!');
      return otp;
    }

    // EmailJS Credentials from class constants
    final String serviceId = _emailServiceId;
    final String publicKey = _emailPublicKey; 
    final String templateId = _emailTemplateId; 
    final String accessToken = _emailPrivateKey;

    debugPrint('🛠 DEBUG: Sending email using Service: $serviceId, Template: $templateId');

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      // Calculate expiry time (15 mins from now)
      final expiryTime = DateTime.now().add(const Duration(minutes: 15));
      final timeString = "${expiryTime.hour.toString().padLeft(2, '0')}:${expiryTime.minute.toString().padLeft(2, '0')}";

      final Map<String, dynamic> body = {
        'lib_version': '3.2.0',
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'email': userEmail,      
          'passcode': otp,       
          'otp_code': otp,       
          'time': timeString,    
        },
      };

      // Add private key if provided
      if (accessToken.isNotEmpty) {
        body['accessToken'] = accessToken;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Real Email Sent SUCCESSFULLY to $userEmail: $otp');
        _showSuccess('Verification code sent to your email!');
      } else {
        // This will tell us EXACTLY why EmailJS is rejecting it
        debugPrint('❌ EmailJS API REJECTED: Status ${response.statusCode}');
        debugPrint('❌ Error Details: ${response.body}');
        debugPrint('📧 Fallback Code (check this while fixing): $otp');
        
        // Show backup code in a long toast (approx 3.5 seconds)
        Fluttertoast.showToast(
          msg: "Backup Verification Code: $otp",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange.shade800,
          textColor: Colors.white,
          fontSize: 16.0
        );
        
        _showError('Email failed (Status ${response.statusCode}). Using backup code.');
      }
    } catch (e) {
      debugPrint('❌ NETWORK ERROR: $e');
      debugPrint('📧 Fallback Code: $otp');
      
      // Show backup code in a long toast (approx 3.5 seconds)
      Fluttertoast.showToast(
        msg: "Backup Verification Code: $otp",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.orange.shade800,
        textColor: Colors.white,
        fontSize: 16.0
      );
      
      _showError('Connection error. Using backup code.');
    }

    return otp;
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
