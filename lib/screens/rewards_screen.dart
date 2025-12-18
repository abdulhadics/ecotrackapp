import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../widgets/animated_badge.dart';
import '../utils/constants.dart';

/// Screen showing badges and achievements
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Badges'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Unlocked', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Available', icon: Icon(Icons.lock)),
          ],
        ),
      ),
      body: Consumer<HiveService>(
        builder: (context, hiveService, child) {
          if (hiveService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUnlockedBadges(hiveService),
              _buildAvailableBadges(hiveService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnlockedBadges(HiveService hiveService) {
    final unlockedBadges = hiveService.getUnlockedBadges();
    final user = hiveService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: AppColors.warning,
                    size: AppConstants.largeIconSize,
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Points',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${user?.totalPoints ?? 0}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${unlockedBadges.length} badges',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Unlocked Badges
          Text(
            'Unlocked Badges (${unlockedBadges.length})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.mediumPadding),

          if (unlockedBadges.isEmpty)
            _buildEmptyState('No badges unlocked yet!', 'Complete habits to earn your first badge.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: AppConstants.mediumPadding,
                mainAxisSpacing: AppConstants.mediumPadding,
              ),
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                final badge = unlockedBadges[index];
                return AnimatedBadge(
                  badge: badge,
                  isNewlyUnlocked: false, // You can track this if needed
                  onTap: () => _showBadgeDetails(badge),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableBadges(HiveService hiveService) {
    final lockedBadges = hiveService.getLockedBadges();
    final user = hiveService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress to Next Badge
          _buildNextBadgeProgress(hiveService, user),

          const SizedBox(height: AppConstants.largePadding),

          // Available Badges
          Text(
            'Available Badges (${lockedBadges.length})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.mediumPadding),

          if (lockedBadges.isEmpty)
            _buildEmptyState('All badges unlocked!', 'Congratulations! You\'ve earned all available badges.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: AppConstants.mediumPadding,
                mainAxisSpacing: AppConstants.mediumPadding,
              ),
              itemCount: lockedBadges.length,
              itemBuilder: (context, index) {
                final badge = lockedBadges[index];
                return AnimatedBadge(
                  badge: badge,
                  isNewlyUnlocked: false,
                  onTap: () => _showBadgeDetails(badge),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNextBadgeProgress(HiveService hiveService, user) {
    final lockedBadges = hiveService.getLockedBadges();
    if (lockedBadges.isEmpty) return const SizedBox.shrink();

    // Find the next badge to unlock
    final nextBadge = lockedBadges.reduce((a, b) => 
        a.requiredPoints < b.requiredPoints ? a : b);
    
    final currentPoints = user?.totalPoints ?? 0;
    final progress = (currentPoints / nextBadge.requiredPoints).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Badge',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Text(
                  nextBadge.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextBadge.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        nextBadge.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        '$currentPoints / ${nextBadge.requiredPoints} points',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              badge.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: Text(
                badge.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  '${badge.requiredPoints} points required',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  badge.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (badge.isUnlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Text(
                    'Unlocked on ${_formatDate(badge.unlockedAt!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
