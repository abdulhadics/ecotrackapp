import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit_model.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../widgets/habit_card.dart';

/// Dynamic habit list that automatically moves habits between pending and completed
class DynamicHabitList extends StatefulWidget {
  final List<Habit> habits;
  final String title;
  final bool showCompletedHabits;
  
  const DynamicHabitList({
    super.key,
    required this.habits,
    required this.title,
    this.showCompletedHabits = false,
  });
  
  @override
  State<DynamicHabitList> createState() => _DynamicHabitListState();
}

class _DynamicHabitListState extends State<DynamicHabitList>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredHabits = widget.habits.where((habit) {
      return widget.showCompletedHabits 
          ? habit.isCompleted 
          : !habit.isCompleted;
    }).toList();
    
    if (filteredHabits.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with count
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Row(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.showCompletedHabits 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredHabits.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.showCompletedHabits 
                        ? AppColors.success
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        // Animated habit list
        SlideTransition(
          position: _slideAnimation,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredHabits.length,
            itemBuilder: (context, index) {
              final habit = filteredHabits[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumPadding,
                  vertical: AppConstants.smallPadding / 2,
                ),
                child: Dismissible(
                  key: Key('dismiss_${habit.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Habit?'),
                        content: const Text('Are you sure you want to delete this habit?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    final hiveService = Provider.of<HiveService>(context, listen: false);
                    hiveService.deleteHabit(habit, context);
                  },
                  child: AnimatedHabitCard(
                    key: ValueKey(habit.id),
                    habit: habit,
                    onCompletionChanged: _onHabitCompletionChanged,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(
            widget.showCompletedHabits 
                ? Icons.check_circle_outline 
                : Icons.pending_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            widget.showCompletedHabits 
                ? 'No completed habits yet'
                : 'No pending habits',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            widget.showCompletedHabits 
                ? 'Complete some habits to see them here!'
                : 'Add some habits to get started!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _onHabitCompletionChanged(Habit habit) {
    // Trigger a rebuild to update the lists
    setState(() {});
  }
}

/// Enhanced habit card with completion change callback
class AnimatedHabitCard extends StatefulWidget {
  final Habit habit;
  final Function(Habit) onCompletionChanged;
  
  const AnimatedHabitCard({
    super.key,
    required this.habit,
    required this.onCompletionChanged,
  });
  
  @override
  State<AnimatedHabitCard> createState() => _AnimatedHabitCardState();
}

class _AnimatedHabitCardState extends State<AnimatedHabitCard>
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
    return HabitCard(habit: widget.habit);
  }
}
