import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';

/// Widget displaying user's points and streak
class PointsBadge extends StatelessWidget {
  final int points;
  final int todaysPoints;
  final int streak;

  const PointsBadge({
    super.key,
    required this.points,
    required this.todaysPoints,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            // Total Points
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: AppConstants.largeIconSize,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  '$points',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Points',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Today's Points and Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Today',
                  '$todaysPoints',
                  Icons.today,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                _buildStatItem(
                  context,
                  'Streak',
                  '$streak days',
                  Icons.local_fire_department,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Motivational Quote
            Text(
              _getMotivationalQuote(points),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: AppConstants.iconSize,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _getMotivationalQuote(int points) {
    if (points == 0) {
      return AppConstants.motivationalQuotes[0];
    } else if (points < 50) {
      return AppConstants.motivationalQuotes[1];
    } else if (points < 100) {
      return AppConstants.motivationalQuotes[2];
    } else if (points < 500) {
      return AppConstants.motivationalQuotes[3];
    } else {
      return AppConstants.motivationalQuotes[4];
    }
  }
}
