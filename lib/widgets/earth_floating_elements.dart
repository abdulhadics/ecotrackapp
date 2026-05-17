import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

/// Earth-themed floating elements for enhanced visual experience
class EarthFloatingElements extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const EarthFloatingElements({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<EarthFloatingElements> createState() => _EarthFloatingElementsState();
}

class _EarthFloatingElementsState extends State<EarthFloatingElements>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // We'll initialize controllers with default values and update them if needed
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    if (widget.isEnabled) {
      _floatingController.repeat(reverse: true);
      _rotationController.repeat();
    }
  }

  void _updateAnimationSpeeds(double intensity) {
    // Higher intensity = faster animations (shorter duration)
    // Duration ranges from 8s (0.1 intensity) to 0.8s (1.0 intensity) roughly
    final floatDuration = Duration(milliseconds: (6000 / (0.5 + intensity * 1.5)).round());
    final rotateDuration = Duration(milliseconds: (12000 / (0.5 + intensity * 1.5)).round());
    
    if (_floatingController.duration != floatDuration) {
      _floatingController.duration = floatDuration;
      if (widget.isEnabled) _floatingController.repeat(reverse: true);
    }
    if (_rotationController.duration != rotateDuration) {
      _rotationController.duration = rotateDuration;
      if (widget.isEnabled) _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  List<String> _getThemeEmojis(String theme) {
    switch (theme) {
      case 'animals':
        return ['🦊', '🐰', '🐼', '🐯', '🐘'];
      case 'fantasy':
        return ['🦄', '🧚', '🐉', '🪄', '✨'];
      case 'space':
        return ['🚀', '🪐', '🌠', '🛸', '👨‍🚀'];
      case 'nature':
      default:
        return ['🍃', '🌿', '🌸', '🦋', '🐝'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        final magic = settings.magicModeSettings;
        if (settings.isMagicMode) {
          _updateAnimationSpeeds(magic.animationIntensity);
        }
        final emojis = _getThemeEmojis(magic.stickerTheme);

        return AnimatedBuilder(
          animation: Listenable.merge([_floatingAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Stack(
              children: [
                // Floating earth elements (Rendered BEHIND content)
                if (widget.isEnabled && settings.isMagicMode)
                  IgnorePointer(
                    child: Stack(
                      children: [
                        // Element 1
                        Positioned(
                          left: 50 + (_floatingAnimation.value * 20),
                          top: 100 + (_floatingAnimation.value * 30),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * 2 * math.pi,
                            child: Opacity(
                              opacity: 0.6 * magic.animationIntensity.clamp(0.5, 1.0),
                              child: Text(
                                emojis[0],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        
                        // Element 2
                        Positioned(
                          right: 80 + (_floatingAnimation.value * 15),
                          top: 200 + (_floatingAnimation.value * 25),
                          child: Transform.rotate(
                            angle: -_rotationAnimation.value * 2 * math.pi,
                            child: Opacity(
                              opacity: 0.5 * magic.animationIntensity.clamp(0.5, 1.0),
                              child: Text(
                                emojis[1],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        
                        // Element 3
                        Positioned(
                          left: 120 + (_floatingAnimation.value * 25),
                          top: 300 + (_floatingAnimation.value * 20),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * math.pi,
                            child: Opacity(
                              opacity: 0.7 * magic.animationIntensity.clamp(0.5, 1.0),
                              child: Text(
                                emojis[2],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        
                        // Element 4
                        Positioned(
                          right: 40 + (_floatingAnimation.value * 30),
                          top: 150 + (_floatingAnimation.value * 35),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * math.pi / 2,
                            child: Opacity(
                              opacity: 0.8 * magic.animationIntensity.clamp(0.5, 1.0),
                              child: Text(
                                emojis[3],
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                        
                        // Element 5
                        Positioned(
                          left: 200 + (_floatingAnimation.value * 20),
                          top: 80 + (_floatingAnimation.value * 40),
                          child: Transform.rotate(
                            angle: -_rotationAnimation.value * math.pi,
                            child: Opacity(
                              opacity: 0.6 * magic.animationIntensity.clamp(0.5, 1.0),
                              child: Text(
                                emojis[4],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Content (Rendered ON TOP of floating elements)
                widget.child,
              ],
            );
          },
        );
      },
    );
  }
}
