import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../models/habit_model.dart';

/// Screen showing weekly progress and analytics
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
      ),
      body: Consumer<HiveService>(
        builder: (context, hiveService, child) {
          if (hiveService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final weeklyData = hiveService.getWeeklyHabits();
          final user = hiveService.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly Chart
                _buildWeeklyChart(context, weeklyData),

                const SizedBox(height: AppConstants.largePadding),

                // Statistics Cards
                _buildStatisticsCards(context, hiveService),

                const SizedBox(height: AppConstants.largePadding),

                // Category Breakdown
                _buildCategoryBreakdown(context, hiveService),

                const SizedBox(height: AppConstants.largePadding),

                // Achievements Preview
                _buildAchievementsPreview(context, hiveService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List weeklyData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt() % 7]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['completed'].toDouble(),
                          color: AppColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, HiveService hiveService) {
    final user = hiveService.currentUser;
    final totalHabits = hiveService.habits.length;
    final completedHabits = hiveService.habits.where((h) => h.isCompleted).length;
    final completionRate = totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Points',
            '${user?.totalPoints ?? 0}',
            Icons.stars,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppConstants.mediumPadding),
        Expanded(
          child: _buildStatCard(
            context,
            'Completion Rate',
            '$completionRate%',
            Icons.trending_up,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
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
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, HiveService hiveService) {
    final categoryStats = <String, int>{};
    
    for (final habit in hiveService.habits) {
      categoryStats[habit.category] = (categoryStats[habit.category] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            ...categoryStats.entries.map((entry) {
              final category = entry.key;
              final count = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: Row(
                  children: [
                    Text(HabitCategory.icons[category] ?? '🌱'),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(category),
                    ),
                    Text(
                      '$count habits',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsPreview(BuildContext context, HiveService hiveService) {
    final unlockedBadges = hiveService.getUnlockedBadges();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            if (unlockedBadges.isEmpty)
              Text(
                'Complete more habits to unlock achievements!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              )
            else
              ...unlockedBadges.take(3).map((badge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  child: Row(
                    children: [
                      Text(
                        badge.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              badge.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
