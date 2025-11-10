import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'widgets/magic_mode_widgets.dart';
import 'widgets/power_mode_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  runApp(EcoTrackApp(settingsService: settingsService));
}

class EcoTrackApp extends StatelessWidget {
  final SettingsService settingsService;
  
  const EcoTrackApp({
    super.key,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HiveService()),
        ChangeNotifierProvider.value(value: settingsService),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: settings.isMagicMode 
                ? MagicModeTheme.themeData 
                : PowerModeTheme.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}