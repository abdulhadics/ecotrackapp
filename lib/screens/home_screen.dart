import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../models/habit_model.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/animation_sound_service.dart';
import '../utils/constants.dart';
import '../widgets/dynamic_habit_list.dart';
import '../widgets/magic_mode_widgets.dart';
import '../widgets/power_mode_widgets.dart';
import '../widgets/earth_floating_elements.dart';
import 'add_habit_screen.dart';
import 'habit_list_screen.dart';
import 'summary_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

/// Main home screen with dashboard
/// Shows today's eco points, habits, and quick actions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const HabitListScreen(),
    const SummaryScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        // Handle Magic Mode background music
        if (settingsService.isMagicMode) {
          MusicService().updateMusic(
            settingsService.magicModeSettings.backgroundMusic,
            settingsService.soundEnabled,
          );
        } else {
          MusicService().stop();
        }

        return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
          bottomNavigationBar: _buildBottomNavigationBar(settingsService),
          floatingActionButton: _buildFloatingActionButton(settingsService),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(SettingsService settingsService) {
    if (settingsService.isMagicMode) {
      return _buildMagicBottomNavigationBar();
    } else {
      return _buildPowerBottomNavigationBar();
    }
  }

  Widget _buildMagicBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: MagicModeTheme.magicBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: MagicModeTheme.magicPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 20)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text('🌱', style: TextStyle(fontSize: 20)),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Text('📊', style: TextStyle(fontSize: 20)),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Text('🏆', style: TextStyle(fontSize: 20)),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 20)),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Text('🎨', style: TextStyle(fontSize: 20)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: PowerModeTheme.powerPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: PowerModeTheme.powerSurface,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco),
          label: 'Habits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Summary',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_outlined),
          activeIcon: Icon(Icons.emoji_events),
          label: 'Rewards',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(SettingsService settingsService) {
    if (_selectedIndex != 0) return const SizedBox.shrink();

    if (settingsService.isMagicMode) {
      return MagicFAB(
        emoji: '🌱',
        onPressed: () => _navigateToAddHabit(),
      );
    } else {
      return FloatingActionButton(
        onPressed: () => _navigateToAddHabit(),
        backgroundColor: PowerModeTheme.powerPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
  }

  void _navigateToAddHabit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
  }
}

/// Dashboard tab showing today's progress with welcome notifications
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _hasShownWelcome = false;

  @override
  void initState() {
    super.initState();
    _showWelcomeNotification();
  }

  Future<void> _showWelcomeNotification() async {
    if (!_hasShownWelcome) {
      await Future.delayed(const Duration(seconds: 1));
      await NotificationService.showWelcomeNotification();
      setState(() {
        _hasShownWelcome = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HiveService, SettingsService>(
      builder: (context, hiveService, settingsService, child) {
        if (hiveService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = hiveService.currentUser;
        final List<Habit> todaysHabits = hiveService.getTodaysHabits();
        final int todaysPoints = hiveService.getTodaysPoints();
        final int completedHabits = hiveService.getTodaysCompletedHabits();

        return Scaffold(
          appBar: _buildAppBar(settingsService, user?.name ?? 'Eco Warrior'),
          body: Container(
            decoration: settingsService.isMagicMode
                ? const BoxDecoration(gradient: MagicModeTheme.magicBackground)
                : null,
            child: settingsService.isMagicMode
                ? EarthFloatingElements(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Points Badge
                          _buildPointsBadge(settingsService, user?.totalPoints ?? 0, todaysPoints, user?.currentStreak ?? 0),

                          const SizedBox(height: AppConstants.largePadding),

                          // Today's Progress
                          _buildTodaysProgress(context, settingsService, todaysHabits, completedHabits, todaysPoints),

                          const SizedBox(height: AppConstants.largePadding),

                          // Quick Actions
                          _buildQuickActions(context, settingsService),

                          const SizedBox(height: AppConstants.largePadding),

                          // Recent Habits
                          _buildRecentHabits(context, settingsService, todaysHabits),

                          const SizedBox(height: AppConstants.largePadding),

                          // Eco Tip or Analytics (based on mode)
                          settingsService.isMagicMode
                              ? _buildEcoTip(context)
                              : _buildAnalytics(context, settingsService, hiveService),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Badge
                        _buildPointsBadge(settingsService, user?.totalPoints ?? 0, todaysPoints, user?.currentStreak ?? 0),

                const SizedBox(height: AppConstants.largePadding),

                // Today's Progress
                        _buildTodaysProgress(context, settingsService, todaysHabits, completedHabits, todaysPoints),

                const SizedBox(height: AppConstants.largePadding),

                // Quick Actions
                        _buildQuickActions(context, settingsService),

                const SizedBox(height: AppConstants.largePadding),

                // Recent Habits
                        _buildRecentHabits(context, settingsService, todaysHabits),

                const SizedBox(height: AppConstants.largePadding),

                        // Analytics for Power Mode
                        _buildAnalytics(context, settingsService, hiveService),
              ],
                    ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SettingsService settingsService, String userName) {
    if (settingsService.isMagicMode) {
      return AppBar(
        title: Text('🌿 Welcome back, $userName!'),
        backgroundColor: MagicModeTheme.magicBackground.colors.first,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text('🎨', style: TextStyle(fontSize: 20)),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      );
    } else {
      return AppBar(
        title: Text('Welcome back, $userName'),
        backgroundColor: PowerModeTheme.powerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      );
    }
  }

  Widget _buildPointsBadge(SettingsService settingsService, int totalPoints, int todaysPoints, int streak) {
    if (settingsService.isMagicMode) {
      return MagicCard(
        glowColor: MagicModeTheme.magicSuccess,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced earth-themed icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: MagicModeTheme.earthGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MagicModeTheme.magicSuccess.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🌍',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalPoints',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: MagicModeTheme.magicSuccess,
                      ),
                    ),
                    Text(
                      'Total Eco Points',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MagicModeTheme.magicSuccess,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: MagicModeTheme.magicAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+$todaysPoints today',
                            style: const TextStyle(
                              color: MagicModeTheme.magicSuccess,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: MagicModeTheme.magicGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$streak day streak',
                            style: const TextStyle(
                              color: MagicModeTheme.magicGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return PowerDataCard(
        title: 'Total Points',
        value: totalPoints.toString(),
        subtitle: '+$todaysPoints today • $streak day streak',
        icon: Icons.eco,
        color: PowerModeTheme.powerSuccess,
      );
    }
  }

  Widget _buildTodaysProgress(BuildContext context, SettingsService settingsService, List todaysHabits, int completedCount, int todaysPoints) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Progress",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    context,
                    'Completed',
                    '$completedCount/${todaysHabits.length}',
                    '✅',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    context,
                    'Points Earned',
                    '$todaysPoints',
                    '⭐',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            LinearProgressIndicator(
              value: todaysHabits.isEmpty ? 0 : (completedCount / todaysHabits.length),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String label, String value, dynamic icon, Color color) {
    return Column(
      children: [
        icon is IconData 
            ? Icon(icon, color: color, size: AppConstants.largeIconSize)
            : Text(icon, style: TextStyle(fontSize: AppConstants.largeIconSize)),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, SettingsService settingsService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppConstants.mediumPadding),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Plant Habit',
                '🌱',
                AppColors.primary,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddHabitScreen()),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: _buildActionCard(
                context,
                'View Garden',
                '🌿',
                AppColors.secondary,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HabitListScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, dynamic icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            children: [
              icon is IconData 
                  ? Icon(icon, color: color, size: AppConstants.largeIconSize)
                  : Text(icon, style: TextStyle(fontSize: AppConstants.largeIconSize)),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHabits(BuildContext context, SettingsService settingsService, List<Habit> todaysHabits) {
    final pendingHabits = todaysHabits.where((habit) => !habit.isCompleted).toList();
    final completedHabits = todaysHabits.where((habit) => habit.isCompleted).toList();
    
    return Column(
      children: [
        // Pending Habits
        if (pendingHabits.isNotEmpty)
          DynamicHabitList(
            habits: pendingHabits,
            title: "Pending Habits",
            showCompletedHabits: false,
          ),
        
        // Completed Habits
        if (completedHabits.isNotEmpty) ...[
          const SizedBox(height: AppConstants.largePadding),
          DynamicHabitList(
            habits: completedHabits,
            title: "Completed Today",
            showCompletedHabits: true,
          ),
        ],
        
        // Empty state if no habits
        if (todaysHabits.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  Text(
                    '🌱',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'No habits for today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Plant your first eco-friendly habit! 🌱',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // View all button if there are many habits
        if (todaysHabits.length > 3)
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HabitListScreen()),
            ),
            child: Text('View all ${todaysHabits.length} habits'),
            ),
          ),
      ],
    );
  }

  Widget _buildEcoTip(BuildContext context) {
    final randomTip = AppConstants.ecoTips[
      DateTime.now().millisecondsSinceEpoch % AppConstants.ecoTips.length
    ];
    
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Row(
          children: [
            const Text(
              '💡',
              style: TextStyle(fontSize: AppConstants.largeIconSize),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eco Tip of the Day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MagicModeTheme.magicPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    randomTip,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, SettingsService settingsService, HiveService hiveService) {
    final weeklyData = hiveService.getWeeklyHabits();
    final chartData = weeklyData.map((data) => ChartData(
      label: _formatDate(data['date'] as DateTime),
      value: (data['completed'] as int).toDouble(),
    )).toList();

    return PowerChart(
      title: 'Weekly Progress',
      data: chartData,
      type: ChartType.bar,
      xAxisLabel: 'Days',
      yAxisLabel: 'Completed Habits',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
