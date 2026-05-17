import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../services/hive_service.dart';
import '../widgets/magic_mode_widgets.dart';
import '../widgets/power_mode_widgets.dart';
import '../widgets/AlgorithmicsCard.dart';
import '../utils/constants.dart';
import '../models/habit_model.dart';
import '../widgets/dynamic_habit_list.dart';
import 'habit_list_screen.dart';
import 'add_habit_screen.dart';
import 'map_deed_screen.dart';
import 'admin_reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final hiveService = Provider.of<HiveService>(context);
        final user = hiveService.currentUser;
        final userName = user?.name ?? 'Eco Warrior';
        final totalPoints = user?.totalPoints ?? 0;
        final streak = user?.currentStreak ?? 0;
        final todaysHabits = hiveService.getTodaysHabits();
        final todaysPoints = hiveService.getTodaysPoints();

        return Scaffold(
          appBar: _buildAppBar(settingsService, userName),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(settingsService, hiveService, todaysHabits, totalPoints, todaysPoints, streak),
              const MapDeedScreen(),
              const AdminReportsScreen(),
            ],
          ),
          bottomNavigationBar: settingsService.isMagicMode 
              ? _buildMagicBottomNavigationBar() 
              : _buildPowerBottomNavigationBar(),
          floatingActionButton: _currentIndex != 0 
              ? null
              : (settingsService.isMagicMode 
                  ? MagicFAB(emoji: '🌱', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddHabitScreen())))
                  : FloatingActionButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddHabitScreen())),
                      backgroundColor: const Color(0xFF00C896),
                      child: const Icon(Icons.add),
                    )),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SettingsService settingsService, String userName) {
    final Uri dashboardUri = Uri.parse('https://supabase.com/dashboard');
    if (settingsService.isMagicMode) {
      return AppBar(
        title: Text('🌿 Welcome, $userName!'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.blueAccent),
            onPressed: () => launchUrl(dashboardUri),
          ),
        ],
      );
    } else {
      return AppBar(
        title: Text('EcoTrack | $userName'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18),
            onPressed: () => launchUrl(dashboardUri),
          ),
        ],
      );
    }
  }

  Widget _buildDashboard(SettingsService settingsService, HiveService hiveService, List<Habit> todaysHabits, int totalPoints, int todaysPoints, int streak) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPointsBadge(settingsService, totalPoints, todaysPoints, streak),
          const SizedBox(height: 24),
          const AlgorithmicsCard(),
          const SizedBox(height: 24),
          _buildQuickEntry(context, settingsService),
          const SizedBox(height: 24),
          _buildRecentHabits(context, settingsService, todaysHabits),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(SettingsService settingsService, int totalPoints, int todaysPoints, int streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Text('🌍', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$totalPoints', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Total Eco Points'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEntry(BuildContext context, SettingsService settingsService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Entry',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: settingsService.isMagicMode ? const Color(0xFF1B5E20) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context, 'Log Trip', Icons.directions_run, const Color(0xFF00C896), () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddHabitScreen()),
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(context, 'View Logs', Icons.list_alt, Colors.blueGrey, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HabitListScreen()),
                );
              }),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHabits(BuildContext context, SettingsService settingsService, List<Habit> habits) {
    return DynamicHabitList(habits: habits, title: "Recent Trip Logs", showCompletedHabits: true);
  }

  Widget _buildMagicBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
        BottomNavigationBarItem(icon: Text('🌱', style: TextStyle(fontSize: 20)), label: 'Trip Logs'),
        BottomNavigationBarItem(icon: Text('🏆', style: TextStyle(fontSize: 20)), label: 'ESG Reports'),
      ],
    );
  }

  Widget _buildPowerBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: const Color(0xFF0D1B2A),
      selectedItemColor: const Color(0xFF00C896),
      unselectedItemColor: Colors.white30,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Trip Logs'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'ESG Reports'),
      ],
    );
  }
}
