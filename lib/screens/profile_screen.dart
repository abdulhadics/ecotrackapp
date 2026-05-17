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
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<HiveService>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
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

                // Email Verification
                _buildVerificationCard(hiveService),

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
              controller: _emailController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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
    final unlockedBadges = hiveService.getUnlockedBadges().length;
    final user = hiveService.currentUser;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: _buildPremiumStatCard(
              header: 'Total Points',
              icon: Icons.emoji_events,
              iconColor: AppColors.success,
              value: '$unlockedBadges',
              label: 'Badges',
            ),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: _buildPremiumStatCard(
              header: 'Habits',
              icon: Icons.local_fire_department,
              iconColor: AppColors.error,
              value: '${user?.currentStreak ?? 0} days',
              label: 'Streak',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatCard({
    required String header,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            header,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(HiveService hiveService) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Notifications
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black87),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Daily eco reminders',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: Switch(
                value: true, 
                onChanged: (value) {},
                activeColor: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'App Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildAppInfoTile(Icons.info, 'Version', AppConstants.appVersion),
            _buildAppInfoTile(Icons.description, 'Description', AppConstants.appDescription),
            _buildAppInfoTile(Icons.eco, 'Made with', 'Flutter & Hive'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  void _saveProfile() async {
    final hiveService = Provider.of<HiveService>(context, listen: false);
    final currentUser = hiveService.currentUser;
    
    if (currentUser == null) return;

    final newEmail = _emailController.text.trim();
    bool emailChanged = newEmail != currentUser.email;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      email: newEmail,
      ecoGoal: _goalController.text.trim(),
      isEmailVerified: emailChanged ? false : currentUser.isEmailVerified,
    );

    final success = await hiveService.updateUser(updatedUser);
    
    if (success && mounted) {
      setState(() => _isEditing = false);
      if (emailChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated. Please verify your new email.')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildVerificationCard(HiveService hiveService) {
    final bool isVerified = hiveService.currentUser?.isEmailVerified ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVerified ? Icons.verified_user : Icons.mail_outline,
                color: isVerified ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'Email Verified' : 'Email Not Verified',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isVerified ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    isVerified 
                        ? 'Great! Your email is confirmed.' 
                        : 'Verify your email to secure your account.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified)
              ElevatedButton(
                onPressed: () => _showOTPDialog(hiveService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Verify Now', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  void _showOTPDialog(HiveService hiveService) async {
    final String sentOTP = await hiveService.sendVerificationOTP();
    final TextEditingController otpController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A 6-digit code has been sent to your email. (Check debug logs in this demo)'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit code',
                border: OutlineInputBorder(),
              ),
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (otpController.text == sentOTP) {
                Navigator.pop(context);
                hiveService.setEmailVerified();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid OTP! Please try again.')),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
