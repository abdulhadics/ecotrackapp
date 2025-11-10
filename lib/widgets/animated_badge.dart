import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/badge_model.dart' as badge_model;
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Animated badge widget with glow effects and celebrations
class AnimatedBadge extends StatefulWidget {
  final badge_model.Badge badge;
  final bool isNewlyUnlocked;
  final VoidCallback? onTap;

  const AnimatedBadge({
    super.key,
    required this.badge,
    this.isNewlyUnlocked = false,
    this.onTap,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Glow animation
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Start animations if badge is newly unlocked
    if (widget.isNewlyUnlocked) {
      _startCelebrationAnimation();
    } else if (widget.badge.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  void _startCelebrationAnimation() {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Start glow animation
    _glowController.repeat(reverse: true);
    
    // Start scale animation
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    // Start rotation animation
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.badge.isUnlocked) {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _scaleAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: widget.badge.isUnlocked
                    ? AppTheme.getAnimatedGlowDecoration(
                        _getBadgeGlowColor(),
                        _glowAnimation.value,
                      )
                    : null,
                child: Card(
                  elevation: widget.badge.isUnlocked ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Container(
                    decoration: widget.badge.isUnlocked
                        ? AppTheme.getGradientDecoration(_getBadgeGradientColors())
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.badge.isUnlocked
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade200,
                              border: Border.all(
                                color: widget.badge.isUnlocked
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.badge.icon,
                                style: TextStyle(
                                  fontSize: widget.badge.isUnlocked ? 32 : 24,
                                  color: widget.badge.isUnlocked
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppConstants.smallPadding),
                          
                          // Badge Name
                          Text(
                            widget.badge.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.badge.isUnlocked
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppConstants.smallPadding),
                          
                          // Badge Description
                          Text(
                            widget.badge.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.badge.isUnlocked
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppConstants.smallPadding),
                          
                          // Points Required
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.smallPadding,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.badge.isUnlocked
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.badge.requiredPoints} pts',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: widget.badge.isUnlocked
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          // Locked indicator
                          if (!widget.badge.isUnlocked) ...[
                            const SizedBox(height: AppConstants.smallPadding),
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ],
                      ),
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

  Color _getBadgeGlowColor() {
    switch (widget.badge.category) {
      case 'Starter':
        return AppColors.glowGreen;
      case 'Points':
        return AppColors.glowAmber;
      case 'Streak':
        return AppColors.glowOrange;
      case 'Water':
        return AppColors.glowBlue;
      case 'Energy':
        return AppColors.glowOrange;
      case 'Waste':
        return AppColors.glowGreen;
      default:
        return AppColors.glowPurple;
    }
  }

  List<Color> _getBadgeGradientColors() {
    switch (widget.badge.category) {
      case 'Starter':
        return [AppColors.primary, AppColors.primaryLight];
      case 'Points':
        return [AppColors.amber, AppColors.sunsetOrange];
      case 'Streak':
        return [AppColors.sunsetOrange, AppColors.coral];
      case 'Water':
        return [AppColors.skyBlue, AppColors.mint];
      case 'Energy':
        return [AppColors.sunsetOrange, AppColors.amber];
      case 'Waste':
        return [AppColors.primary, AppColors.accent];
      default:
        return [AppColors.lavender, AppColors.glowPurple];
    }
  }
}
