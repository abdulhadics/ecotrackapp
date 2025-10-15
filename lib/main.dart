import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'services/hive_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: AppConstants.notificationChannelId,
        channelName: AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        defaultColor: AppColors.primary,
        ledColor: AppColors.primary,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );
  
  // Request notification permissions
  await AwesomeNotifications().requestPermissionToSendNotifications();
  
  runApp(const EcoTrackApp());
}

class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HiveService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}