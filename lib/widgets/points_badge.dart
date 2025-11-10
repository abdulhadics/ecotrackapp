import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Enhanced widget displaying user's points and streak with glow effects
class PointsBadge extends StatefulWidget {
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
  State<PointsBadge> createState() => _PointsBadgeState();
}

class _PointsBadgeState extends State<PointsBadge>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: AppTheme.getAnimatedGlowDecoration(
              AppColors.glowGreen,
              _glowAnimation.value,
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                decoration: AppTheme.getGradientDecoration([
                  AppColors.primary,
                  AppColors.primaryLight,
                  AppColors.accent,
                ]),
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  children: [
                    // Enhanced Total Points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: AppConstants.largeIconSize,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          '${widget.points}',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          'Points',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.mediumPadding),

                    // Enhanced Today's Points and Streak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Today',
                          '${widget.todaysPoints}',
                          Icons.today,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        _buildStatItem(
                          context,
                          'Streak',
                          '${widget.streak} days',
                          Icons.local_fire_department,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.mediumPadding),

                    // Enhanced Motivational Quote
                    Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getMotivationalQuote(widget.points),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: AppConstants.iconSize,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
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
