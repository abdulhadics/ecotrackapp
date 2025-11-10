import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Comprehensive Animation Service for Magic Mode
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  /// Play sparkle animation
  static void playSparkleAnimation(
    BuildContext context,
    GlobalKey widgetKey, {
    int sparkleCount = 6,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final RenderBox? renderBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    for (int i = 0; i < sparkleCount; i++) {
      _createSparkleOverlay(
        context,
        position,
        size,
        i,
        duration,
      );
    }
  }

  static void _createSparkleOverlay(
    BuildContext context,
    Offset position,
    Size size,
    int index,
    Duration duration,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SparkleWidget(
        position: position,
        size: size,
        index: index,
        duration: duration,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Play bounce animation
  static void playBounceAnimation(
    AnimationController controller, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    controller.duration = duration;
    controller.forward().then((_) {
      controller.reverse();
    });
  }

  /// Play celebration animation
  static void playCelebrationAnimation(
    BuildContext context,
    GlobalKey widgetKey, {
    String emoji = '🎉',
    int count = 8,
  }) {
    final RenderBox? renderBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    for (int i = 0; i < count; i++) {
      _createCelebrationOverlay(context, position, size, emoji, i);
    }
  }

  static void _createCelebrationOverlay(
    BuildContext context,
    Offset position,
    Size size,
    String emoji,
    int index,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationWidget(
        position: position,
        size: size,
        emoji: emoji,
        index: index,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Play progress completion animation
  static void playProgressCompleteAnimation(
    BuildContext context,
    GlobalKey widgetKey,
  ) {
    playSparkleAnimation(context, widgetKey, sparkleCount: 12);
    playCelebrationAnimation(context, widgetKey, emoji: '✨', count: 6);
  }

  /// Play habit completion animation
  static void playHabitCompleteAnimation(
    BuildContext context,
    GlobalKey widgetKey,
    String habitEmoji,
  ) {
    playSparkleAnimation(context, widgetKey, sparkleCount: 8);
    playCelebrationAnimation(context, widgetKey, emoji: habitEmoji, count: 4);
  }

  /// Play badge unlock animation
  static void playBadgeUnlockAnimation(
    BuildContext context,
    GlobalKey widgetKey,
    String badgeEmoji,
  ) {
    playSparkleAnimation(context, widgetKey, sparkleCount: 15);
    playCelebrationAnimation(context, widgetKey, emoji: badgeEmoji, count: 6);
    
    // Special badge unlock effect
    _createBadgeUnlockOverlay(context, widgetKey, badgeEmoji);
  }

  static void _createBadgeUnlockOverlay(
    BuildContext context,
    GlobalKey widgetKey,
    String badgeEmoji,
  ) {
    final RenderBox? renderBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _BadgeUnlockWidget(
        position: position,
        size: size,
        emoji: badgeEmoji,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

/// Sparkle Widget for overlay animations
class _SparkleWidget extends StatefulWidget {
  final Offset position;
  final Size size;
  final int index;
  final Duration duration;
  final VoidCallback onComplete;

  const _SparkleWidget({
    required this.position,
    required this.size,
    required this.index,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_SparkleWidget> createState() => _SparkleWidgetState();
}

class _SparkleWidgetState extends State<_SparkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = (widget.index * 60) * (math.pi / 180);
        final distance = _animation.value * 60;
        final x = math.cos(angle) * distance;
        final y = math.sin(angle) * distance;

        return Positioned(
          left: widget.position.dx + widget.size.width / 2 + x - 12,
          top: widget.position.dy + widget.size.height / 2 + y - 12,
          child: Opacity(
            opacity: 1 - _animation.value,
            child: Transform.scale(
              scale: 0.5 + (_animation.value * 0.5),
              child: const Text(
                '✨',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Celebration Widget for overlay animations
class _CelebrationWidget extends StatefulWidget {
  final Offset position;
  final Size size;
  final String emoji;
  final int index;
  final VoidCallback onComplete;

  const _CelebrationWidget({
    required this.position,
    required this.size,
    required this.emoji,
    required this.index,
    required this.onComplete,
  });

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = (widget.index * 45) * (math.pi / 180);
        final distance = _animation.value * 100;
        final x = math.cos(angle) * distance;
        final y = math.sin(angle) * distance - (_animation.value * 50);

        return Positioned(
          left: widget.position.dx + widget.size.width / 2 + x - 16,
          top: widget.position.dy + widget.size.height / 2 + y - 16,
          child: Opacity(
            opacity: 1 - _animation.value,
            child: Transform.scale(
              scale: 0.8 + (_animation.value * 0.2),
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Badge Unlock Widget for special animations
class _BadgeUnlockWidget extends StatefulWidget {
  final Offset position;
  final Size size;
  final String emoji;
  final VoidCallback onComplete;

  const _BadgeUnlockWidget({
    required this.position,
    required this.size,
    required this.emoji,
    required this.onComplete,
  });

  @override
  State<_BadgeUnlockWidget> createState() => _BadgeUnlockWidgetState();
}

class _BadgeUnlockWidgetState extends State<_BadgeUnlockWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOut),
    );

    _scaleController.forward();
    _rotateController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx + widget.size.width / 2 - 40,
          top: widget.position.dy + widget.size.height / 2 - 40,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * math.pi,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sound Service for Magic Mode
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isEnabled = true;

  /// Enable or disable sound effects
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Play button tap sound
  void playButtonTap() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    // TODO: Play actual sound effect
    _logSound('button_tap');
  }

  /// Play habit completion sound
  void playHabitComplete() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
    // TODO: Play actual sound effect
    _logSound('habit_complete');
  }

  /// Play badge unlock sound
  void playBadgeUnlock() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
    // TODO: Play actual sound effect
    _logSound('badge_unlock');
  }

  /// Play progress complete sound
  void playProgressComplete() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
    // TODO: Play actual sound effect
    _logSound('progress_complete');
  }

  /// Play error sound
  void playError() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    // TODO: Play actual sound effect
    _logSound('error');
  }

  /// Play success sound
  void playSuccess() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    // TODO: Play actual sound effect
    _logSound('success');
  }

  /// Play swipe sound
  void playSwipe() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
    // TODO: Play actual sound effect
    _logSound('swipe');
  }

  /// Play notification sound
  void playNotification() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    // TODO: Play actual sound effect
    _logSound('notification');
  }

  /// Play celebration sound
  void playCelebration() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
    // TODO: Play actual sound effect
    _logSound('celebration');
  }

  void _logSound(String soundName) {
    // Debug logging for sound effects
    print('🔊 Playing sound: $soundName');
  }
}

/// Haptic Feedback Service
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;

  /// Enable or disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Light impact for subtle feedback
  void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium impact for moderate feedback
  void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for strong feedback
  void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection click for UI interactions
  void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Success pattern for positive actions
  void successPattern() {
    if (!_isEnabled) return;
    // Custom success pattern
    lightImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      mediumImpact();
    });
  }

  /// Error pattern for negative actions
  void errorPattern() {
    if (!_isEnabled) return;
    // Custom error pattern
    heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      heavyImpact();
    });
  }

  /// Celebration pattern for achievements
  void celebrationPattern() {
    if (!_isEnabled) return;
    // Custom celebration pattern
    lightImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      heavyImpact();
    });
  }
}

/// Animation Controller Manager for efficient resource management
class AnimationControllerManager {
  static final Map<String, AnimationController> _controllers = {};

  /// Get or create an animation controller
  static AnimationController getController(
    String key,
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (_controllers.containsKey(key)) {
      return _controllers[key]!;
    }

    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _controllers[key] = controller;
    return controller;
  }

  /// Dispose a specific controller
  static void disposeController(String key) {
    _controllers[key]?.dispose();
    _controllers.remove(key);
  }

  /// Dispose all controllers
  static void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// Performance Monitor for animations
class AnimationPerformanceMonitor {
  static final Map<String, List<Duration>> _timings = {};

  /// Start timing an animation
  static void startTiming(String animationName) {
    // Implementation would track animation start time
  }

  /// End timing an animation
  static void endTiming(String animationName) {
    // Implementation would track animation end time and calculate duration
  }

  /// Get average timing for an animation
  static Duration getAverageTiming(String animationName) {
    final timings = _timings[animationName];
    if (timings == null || timings.isEmpty) {
      return Duration.zero;
    }

    final total = timings.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );

    return Duration(
      microseconds: total.inMicroseconds ~/ timings.length,
    );
  }

  /// Clear all timings
  static void clearTimings() {
    _timings.clear();
  }
}
