import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../widgets/points_badge.dart';
import '../widgets/habit_card.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';
import 'habit_list_screen.dart';
import 'summary_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToAddHabit(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _navigateToAddHabit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
  }
}

/// Dashboard tab showing today's progress
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveService>(
      builder: (context, hiveService, child) {
        if (hiveService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = hiveService.currentUser;
        final todaysHabits = hiveService.getTodaysHabits();
        final todaysPoints = hiveService.getTodaysPoints();
        final completedHabits = hiveService.getTodaysCompletedHabits();

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome back, ${user?.name ?? 'Eco Warrior'}!'),
            actions: [
              IconButton(
                icon: Icon(user?.isDarkMode == true ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => hiveService.toggleDarkMode(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Badge
                PointsBadge(
                  points: user?.totalPoints ?? 0,
                  todaysPoints: todaysPoints,
                  streak: user?.currentStreak ?? 0,
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Today's Progress
                _buildTodaysProgress(context, todaysHabits, completedHabits, todaysPoints),

                const SizedBox(height: AppConstants.largePadding),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: AppConstants.largePadding),

                // Recent Habits
                _buildRecentHabits(context, todaysHabits),

                const SizedBox(height: AppConstants.largePadding),

                // Eco Tip
                _buildEcoTip(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaysProgress(BuildContext context, List todaysHabits, int completedHabits, int todaysPoints) {
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
                    '$completedHabits/${todaysHabits.length}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    context,
                    'Points Earned',
                    '$todaysPoints',
                    Icons.stars,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            LinearProgressIndicator(
              value: todaysHabits.isEmpty ? 0 : completedHabits / todaysHabits.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppConstants.largeIconSize),
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

  Widget _buildQuickActions(BuildContext context) {
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
                'Add Habit',
                Icons.add_circle,
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
                'View All',
                Icons.list,
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

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            children: [
              Icon(icon, color: color, size: AppConstants.largeIconSize),
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

  Widget _buildRecentHabits(BuildContext context, List todaysHabits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Habits",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppConstants.mediumPadding),
        if (todaysHabits.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: Colors.grey.shade400,
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
                    'Add your first eco-friendly habit!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...todaysHabits.take(3).map((habit) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: HabitCard(habit: habit),
          )),
        if (todaysHabits.length > 3)
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HabitListScreen()),
            ),
            child: Text('View all ${todaysHabits.length} habits'),
          ),
      ],
    );
  }

  Widget _buildEcoTip(BuildContext context) {
    final randomTip = AppConstants.ecoTips[
      DateTime.now().millisecondsSinceEpoch % AppConstants.ecoTips.length
    ];
    
    return Card(
      color: AppColors.primaryLight.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: AppColors.warning,
              size: AppConstants.largeIconSize,
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
                      color: AppColors.primary,
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
}
