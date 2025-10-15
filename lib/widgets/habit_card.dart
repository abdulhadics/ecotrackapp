import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit_model.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

/// Widget displaying a single habit with completion toggle
class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _toggleHabit(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Row(
            children: [
              // Completion Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: habit.isCompleted ? AppColors.success : Colors.grey.shade300,
                  border: Border.all(
                    color: habit.isCompleted ? AppColors.success : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: habit.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),

              const SizedBox(width: AppConstants.mediumPadding),

              // Habit Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    Row(
                      children: [
                        Text(
                          HabitCategory.icons[habit.category] ?? '🌱',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: Text(
                            habit.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: habit.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                              color: habit.isCompleted 
                                  ? Colors.grey 
                                  : null,
                            ),
                          ),
                        ),
                        // Points Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${habit.points}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        habit.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          decoration: habit.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: AppConstants.smallPadding),

                    // Category and Time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(habit.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            habit.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(habit.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(habit.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
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
      ),
    );
  }

  void _toggleHabit(BuildContext context) {
    final hiveService = Provider.of<HiveService>(context, listen: false);
    
    if (habit.isCompleted) {
      // Mark as incomplete
      final updatedHabit = habit.copyWith(isCompleted: false);
      hiveService.updateHabit(updatedHabit);
    } else {
      // Mark as complete
      hiveService.completeHabit(habit);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case HabitCategory.water:
        return AppColors.waterColor;
      case HabitCategory.energy:
        return AppColors.energyColor;
      case HabitCategory.waste:
        return AppColors.wasteColor;
      case HabitCategory.transport:
        return AppColors.transportColor;
      case HabitCategory.food:
        return AppColors.foodColor;
      default:
        return AppColors.generalColor;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitDate = DateTime(date.year, date.month, date.day);

    if (habitDate == today) {
      return 'Today';
    } else if (habitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
