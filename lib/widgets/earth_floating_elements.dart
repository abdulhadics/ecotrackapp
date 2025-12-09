import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  @override
  void dispose() {
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Floating earth elements (Rendered BEHIND content)
            if (widget.isEnabled)
              IgnorePointer(
                child: Stack(
                  children: [
                    // Floating leaves
                    Positioned(
                      left: 50 + (_floatingAnimation.value * 20),
                      top: 100 + (_floatingAnimation.value * 30),
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * math.pi,
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            '🍃',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      right: 80 + (_floatingAnimation.value * 15),
                      top: 200 + (_floatingAnimation.value * 25),
                      child: Transform.rotate(
                        angle: -_rotationAnimation.value * 2 * math.pi,
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            '🌿',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    
                    // Floating flowers
                    Positioned(
                      left: 120 + (_floatingAnimation.value * 25),
                      top: 300 + (_floatingAnimation.value * 20),
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * math.pi,
                        child: Opacity(
                          opacity: 0.7,
                          child: Text(
                            '🌸',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    
                    // Floating butterflies
                    Positioned(
                      right: 40 + (_floatingAnimation.value * 30),
                      top: 150 + (_floatingAnimation.value * 35),
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * math.pi / 2,
                        child: Opacity(
                          opacity: 0.8,
                          child: Text(
                            '🦋',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                    
                    // Floating bees
                    Positioned(
                      left: 200 + (_floatingAnimation.value * 20),
                      top: 80 + (_floatingAnimation.value * 40),
                      child: Transform.rotate(
                        angle: -_rotationAnimation.value * math.pi,
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            '🐝',
                            style: TextStyle(fontSize: 18),
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
  }
}
