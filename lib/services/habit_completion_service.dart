import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/habit_model.dart';
import '../models/badge_model.dart' as badge_model;
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/animated_badge.dart';

/// Enhanced habit completion service with dynamic updates and reward popups
class HabitCompletionService {
  static Future<void> completeHabitWithRewards(
    BuildContext context,
    Habit habit,
    HiveService hiveService,
  ) async {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Complete the habit
    hiveService.completeHabit(habit, context);
    
    // After completion, use HiveService's own badge logic and user state
    final user = hiveService.currentUser;
    if (user != null) {
      // HiveService already checks and unlocks badges when points change.
      // We only show a generic completion notification here.
      await NotificationService.showHabitCompletionNotification(
        habit.title,
        habit.points,
      );
    }
  }
  
  static Future<void> _showBadgeRewardPopup(
    BuildContext context,
    badge_model.Badge badge,
  ) async {
    // Haptic feedback for badge unlock
    HapticFeedback.heavyImpact();
    
    // Show celebration popup
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BadgeRewardPopup(badge: badge),
    );
  }
}

/// Popup widget for showing badge rewards
class BadgeRewardPopup extends StatefulWidget {
  final badge_model.Badge badge;
  
  const BadgeRewardPopup({
    super.key,
    required this.badge,
  });
  
  @override
  State<BadgeRewardPopup> createState() => _BadgeRewardPopupState();
}

class _BadgeRewardPopupState extends State<BadgeRewardPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Start animations
    _scaleController.forward();
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    _glowController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: AppTheme.getAnimatedGlowDecoration(
                  AppColors.glowAmber,
                  _glowAnimation.value,
                ),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: AppTheme.getGradientDecoration([
                      AppColors.amber,
                      AppColors.sunsetOrange,
                      AppColors.coral,
                    ]),
                    padding: const EdgeInsets.all(AppConstants.largePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Celebration emoji
                        Text(
                          '🎉',
                          style: const TextStyle(fontSize: 48),
                        ),
                        
                        const SizedBox(height: AppConstants.mediumPadding),
                        
                        // Badge icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.badge.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.mediumPadding),
                        
                        // Title
                        Text(
                          'Badge Unlocked!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.smallPadding),
                        
                        // Badge name
                        Text(
                          widget.badge.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.smallPadding),
                        
                        // Badge description
                        Text(
                          widget.badge.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppConstants.largePadding),
                        
                        // Points earned
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.mediumPadding,
                            vertical: AppConstants.smallPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                '${widget.badge.requiredPoints} Points Earned!',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.largePadding),
                        
                        // Close button
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.amber,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.largePadding,
                              vertical: AppConstants.mediumPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Awesome! 🌟',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
