import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';

/// Screen for user profile and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<HiveService>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _goalController.text = user.ecoGoal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Consumer<HiveService>(
        builder: (context, hiveService, child) {
          if (hiveService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = hiveService.currentUser;
          if (user == null) {
            return const Center(child: Text('No user data found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),

                const SizedBox(height: AppConstants.largePadding),

                // Profile Information
                _buildProfileInfo(user),

                const SizedBox(height: AppConstants.largePadding),

                // Statistics
                _buildStatistics(hiveService),

                const SizedBox(height: AppConstants.largePadding),

                // Settings
                _buildSettings(hiveService),

                const SizedBox(height: AppConstants.largePadding),

                // App Information
                _buildAppInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user.avatar,
                style: const TextStyle(fontSize: 40),
              ),
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Name
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.smallPadding),

            // Eco Goal
            Text(
              user.ecoGoal,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Join Date
            Text(
              'Member since ${_formatDate(user.joinDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Name Field
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Email Field
            TextFormField(
              initialValue: user.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Eco Goal Field
            TextFormField(
              controller: _goalController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Eco Goal',
                prefixIcon: Icon(Icons.flag),
                hintText: 'What\'s your environmental goal?',
              ),
              maxLines: 2,
            ),

            if (_isEditing) ...[
              const SizedBox(height: AppConstants.mediumPadding),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(HiveService hiveService) {
    final totalHabits = hiveService.habits.length;
    final completedHabits = hiveService.habits.where((h) => h.isCompleted).length;
    final unlockedBadges = hiveService.getUnlockedBadges().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Points',
                    '${hiveService.currentUser?.totalPoints ?? 0}',
                    Icons.stars,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Habits',
                    '$completedHabits/$totalHabits',
                    Icons.checklist,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Badges',
                    '$unlockedBadges',
                    Icons.emoji_events,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Streak',
                    '${hiveService.currentUser?.currentStreak ?? 0} days',
                    Icons.local_fire_department,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettings(HiveService hiveService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Dark Mode Toggle
            ListTile(
              leading: Icon(
                hiveService.currentUser?.isDarkMode == true 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                hiveService.currentUser?.isDarkMode == true 
                    ? 'Currently enabled' 
                    : 'Currently disabled',
              ),
              trailing: Switch(
                value: hiveService.currentUser?.isDarkMode ?? false,
                onChanged: (value) => hiveService.toggleDarkMode(),
              ),
            ),

            const Divider(),

            // Notifications
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Daily eco reminders'),
              trailing: Switch(
                value: true, // This would be connected to actual notification settings
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Version'),
              subtitle: Text(AppConstants.appVersion),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: Text(AppConstants.appDescription),
            ),
            ListTile(
              leading: const Icon(Icons.eco),
              title: const Text('Made with'),
              subtitle: const Text('Flutter & Hive'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    final hiveService = Provider.of<HiveService>(context, listen: false);
    final currentUser = hiveService.currentUser;
    
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      ecoGoal: _goalController.text.trim(),
    );

    final success = await hiveService.updateUser(updatedUser);
    
    if (success && mounted) {
      setState(() => _isEditing = false);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
