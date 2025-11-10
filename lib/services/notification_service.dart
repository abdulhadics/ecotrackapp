import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Service for handling notifications and celebrations
class NotificationService {
  static const String channelKey = 'eco_reminders';
  static const String channelName = 'Eco Reminders';
  static const String channelDescription = 'Daily reminders for eco-friendly habits';

  /// Initialize notification service
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: channelName,
          channelDescription: channelDescription,
          defaultColor: AppColors.primary,
          ledColor: AppColors.primary,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    // Request permission
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  /// Show welcome notification
  static Future<void> showWelcomeNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: channelKey,
        title: '🌱 Welcome to EcoTrack!',
        body: 'Start your eco-friendly journey today! Complete your first habit to earn points.',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Social,
        wakeUpScreen: true,
        fullScreenIntent: false,
      ),
    );
  }

  /// Show badge unlocked notification
  static Future<void> showBadgeUnlockedNotification(String badgeName, String icon) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: '🎉 Badge Unlocked!',
        body: 'Congratulations! You earned the $badgeName badge! $icon',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Social,
        wakeUpScreen: true,
        fullScreenIntent: false,
      ),
    );
  }

  /// Show habit completion celebration
  static Future<void> showHabitCompletionNotification(String habitTitle, int points) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: '✨ Habit Completed!',
        body: 'Great job! You completed "$habitTitle" and earned $points points! 🌱',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Social,
        wakeUpScreen: false,
        fullScreenIntent: false,
      ),
    );
  }

  /// Show daily reminder
  static Future<void> showDailyReminder() async {
    final quotes = AppConstants.motivationalQuotes;
    final randomQuote = quotes[DateTime.now().day % quotes.length];
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: '🌿 Daily Eco Reminder',
        body: randomQuote,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
        fullScreenIntent: false,
      ),
    );
  }

  /// Show streak milestone notification
  static Future<void> showStreakMilestoneNotification(int streakDays) async {
    String message = '';
    String emoji = '';
    
    if (streakDays == 7) {
      message = 'Amazing! You\'ve maintained a 7-day streak! 🔥';
      emoji = '🔥';
    } else if (streakDays == 30) {
      message = 'Incredible! You\'ve maintained a 30-day streak! 🏆';
      emoji = '🏆';
    } else if (streakDays % 10 == 0) {
      message = 'Fantastic! You\'ve maintained a $streakDays-day streak! 🌟';
      emoji = '🌟';
    }

    if (message.isNotEmpty) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: channelKey,
          title: '$emoji Streak Milestone!',
          body: message,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Social,
          wakeUpScreen: true,
          fullScreenIntent: false,
        ),
      );
    }
  }

  /// Show points milestone notification
  static Future<void> showPointsMilestoneNotification(int points) async {
    String message = '';
    String emoji = '';
    
    if (points == 100) {
      message = 'Congratulations! You\'ve earned 100 eco points! 🌟';
      emoji = '🌟';
    } else if (points == 500) {
      message = 'Amazing! You\'ve earned 500 eco points! 🦸‍♀️';
      emoji = '🦸‍♀️';
    } else if (points == 1000) {
      message = 'Legendary! You\'ve earned 1000 eco points! 👑';
      emoji = '👑';
    } else if (points % 250 == 0 && points > 0) {
      message = 'Great progress! You\'ve earned $points eco points! 🎯';
      emoji = '🎯';
    }

    if (message.isNotEmpty) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: channelKey,
          title: '$emoji Points Milestone!',
          body: message,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Social,
          wakeUpScreen: true,
          fullScreenIntent: false,
        ),
      );
    }
  }

  /// Schedule daily reminders
  static Future<void> scheduleDailyReminders() async {
    for (int hour in AppConstants.reminderHours) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: hour,
          channelKey: channelKey,
          title: '🌿 Eco Reminder',
          body: 'Don\'t forget to complete your eco-friendly habits today!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          hour: hour,
          minute: 0,
          second: 0,
          repeats: true,
        ),
      );
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
