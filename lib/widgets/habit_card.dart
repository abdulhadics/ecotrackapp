import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/habit_model.dart';
import '../services/hive_service.dart';
import '../services/habit_completion_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Widget displaying a single habit with completion toggle and modern animations
class HabitCard extends StatefulWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with TickerProviderStateMixin {
  late AnimationController _completionController;
  late AnimationController _glowController;
  late Animation<double> _completionAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _completionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.habit.isCompleted) {
      _completionController.value = 1.0;
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _completionController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        final intensity = settings.isMagicMode ? settings.magicModeSettings.animationIntensity : 1.0;
        
        return AnimatedBuilder(
          animation: Listenable.merge([_completionAnimation, _glowAnimation]),
          builder: (context, child) {
            return Container(
              decoration: widget.habit.isCompleted
                  ? AppTheme.getAnimatedGlowDecoration(
                      AppColors.glowGreen,
                      _glowAnimation.value,
                      intensity: intensity,
                    )
                  : null,
          child: Card(
            elevation: widget.habit.isCompleted ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Row(
                children: [
                  // Enhanced Completion Button
                  GestureDetector(
                    onTap: () => _toggleHabit(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.habit.isCompleted 
                            ? AppColors.success 
                            : Colors.grey.shade300,
                        border: Border.all(
                          color: widget.habit.isCompleted 
                              ? AppColors.success 
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        boxShadow: widget.habit.isCompleted ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: widget.habit.isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                                key: ValueKey('check'),
                              )
                            : const Icon(
                                Icons.add,
                                color: Colors.grey,
                                size: 18,
                                key: ValueKey('add'),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.mediumPadding),

                  // Enhanced Habit Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Category with enhanced styling
                        Row(
                          children: [
                            Text(
                              HabitCategory.icons[widget.habit.category] ?? '🌱',
                              style: TextStyle(
                                fontSize: 18,
                                color: widget.habit.isCompleted 
                                    ? Colors.grey.shade500 
                                    : _getCategoryColor(widget.habit.category),
                              ),
                            ),
                            const SizedBox(width: AppConstants.smallPadding),
                            Expanded(
                              child: Text(
                                widget.habit.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: widget.habit.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : TextDecoration.none,
                                  color: widget.habit.isCompleted 
                                      ? Colors.grey.shade500 
                                      : null,
                                ),
                              ),
                            ),
                            // Enhanced Points Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.smallPadding,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: widget.habit.isCompleted
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.success.withOpacity(0.2),
                                          AppColors.success.withOpacity(0.1),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.2),
                                          AppColors.primary.withOpacity(0.1),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.habit.isCompleted
                                      ? AppColors.success.withOpacity(0.3)
                                      : AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '+${widget.habit.points}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: widget.habit.isCompleted
                                      ? AppColors.success
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (widget.habit.description.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.smallPadding),
                          Text(
                            widget.habit.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.habit.isCompleted 
                                  ? Colors.grey.shade500 
                                  : Colors.grey.shade600,
                              decoration: widget.habit.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: AppConstants.smallPadding),

                        // Enhanced Category and Time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.smallPadding,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(widget.habit.category).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getCategoryColor(widget.habit.category).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.habit.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getCategoryColor(widget.habit.category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(widget.habit.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
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
      },
    );
  },
);
  }

  void _toggleHabit(BuildContext context) async {
    final hiveService = Provider.of<HiveService>(context, listen: false);
    
    if (widget.habit.isCompleted) {
      // Mark as incomplete
      final updatedHabit = widget.habit.copyWith(isCompleted: false);
      hiveService.updateHabit(updatedHabit);
      
      // Stop glow animation
      _glowController.stop();
      _completionController.reverse();
    } else {
      // Mark as complete with rewards and popups
      await HabitCompletionService.completeHabitWithRewards(
        context,
        widget.habit,
        hiveService,
      );
      
      // Start animations
      _completionController.forward();
      _glowController.repeat(reverse: true);
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
