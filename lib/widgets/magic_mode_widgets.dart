import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Magic Mode Theme with vibrant, child-friendly colors and animations
class MagicModeTheme {
  // Enhanced Green Earth Color Palette for Magic Mode
  static const Color magicPrimary = Color(0xFF2E7D32); // Deep Forest Green
  static const Color magicSecondary = Color(0xFF4CAF50); // Bright Leaf Green
  static const Color magicAccent = Color(0xFF66BB6A); // Fresh Green
  static const Color magicGold = Color(0xFFFFD93D); // Golden Sun
  static const Color magicOrange = Color(0xFFFF8A65); // Sunset Orange
  static const Color magicBlue = Color(0xFF42A5F5); // Sky Blue
  static const Color magicGreen = Color(0xFF7ED321); // Forest Magic
  static const Color magicRed = Color(0xFFFF6B6B); // Earth Red
  
  // Earth-Themed Status Colors
  static const Color magicSuccess = Color(0xFF2E7D32); // Forest Green
  static const Color magicWarning = Color(0xFFF57C00); // Autumn Orange
  static const Color magicError = Color(0xFFD32F2F); // Earth Red
  static const Color magicInfo = Color(0xFF1976D2); // Sky Blue
  
  // Additional Earth Colors
  static const Color earthBrown = Color(0xFF8D6E63);
  static const Color mossGreen = Color(0xFF689F38);
  static const Color sageGreen = Color(0xFF9CCC65);
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color barkBrown = Color(0xFF5D4037);
  
  // Enhanced Earth-Themed Background gradients
  static const LinearGradient magicBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F5E8), // Light Sage Green
      Color(0xFFF1F8E9), // Cream Green
      Color(0xFFE0F2F1), // Light Mint
    ],
  );
  
  static const LinearGradient magicCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF9FBE7), // Cream Green
    ],
  );

  // Earth-themed gradients for special elements
  static const LinearGradient earthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4CAF50), // Leaf Green
      Color(0xFF2E7D32), // Forest Green
    ],
  );

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF42A5F5), // Sky Blue
      Color(0xFF1976D2), // Deep Blue
    ],
  );

  /// Get Magic Mode theme data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: magicPrimary,
        secondary: magicSecondary,
        tertiary: magicAccent,
        surface: Colors.white,
        background: Color(0xFFF8F9FF),
        error: magicRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.black,
        onSurface: Color(0xFF2D3748),
        onBackground: Color(0xFF2D3748),
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: magicPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: magicPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: magicPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF2D3748),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF2D3748),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color(0xFF718096),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: magicPrimary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: magicPrimary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: magicPrimary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
    );
  }
}

/// Enhanced Earth-Themed Animated Sticker Widget for Magic Mode
class MagicSticker extends StatefulWidget {
  final String emoji;
  final double size;
  final bool isAnimated;
  final VoidCallback? onTap;
  final String? soundEffect;
  final bool showEarthGlow;

  const MagicSticker({
    super.key,
    required this.emoji,
    this.size = 48.0,
    this.isAnimated = true,
    this.onTap,
    this.soundEffect,
    this.showEarthGlow = true,
  });

  @override
  State<MagicSticker> createState() => _MagicStickerState();
}

class _MagicStickerState extends State<MagicSticker>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeOut),
    );

    if (widget.isAnimated) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          _playSoundEffect();
          _bounceController.forward().then((_) {
            _bounceController.reset();
          });
          _sparkleController.forward().then((_) {
            _sparkleController.reset();
          });
          widget.onTap!();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bounceAnimation,
          _pulseAnimation,
          _sparkleAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Main sticker with earth-themed glow
              Transform.scale(
                scale: widget.isAnimated ? _pulseAnimation.value : 1.0,
                child: Transform.translate(
                  offset: Offset(0, -_bounceAnimation.value * 10),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.showEarthGlow ? MagicModeTheme.earthGradient : null,
                      boxShadow: [
                        BoxShadow(
                          color: MagicModeTheme.magicSuccess.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: MagicModeTheme.magicAccent.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: TextStyle(fontSize: widget.size * 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Enhanced Earth-themed sparkle effect
              if (_sparkleAnimation.value > 0)
                ...List.generate(8, (index) {
                  final angle = (index * 45) * (math.pi / 180);
                  final distance = _sparkleAnimation.value * 40;
                  final x = math.cos(angle) * distance;
                  final y = math.sin(angle) * distance;
                  
                  // Use earth-themed sparkles
                  final sparkles = ['✨', '🌟', '💫', '🌿', '🍃', '🌱', '⭐', '💚'];
                  final sparkle = sparkles[index % sparkles.length];
                  
                  return Positioned(
                    left: widget.size / 2 + x - 8,
                    top: widget.size / 2 + y - 8,
                    child: Opacity(
                      opacity: 1 - _sparkleAnimation.value,
                      child: Transform.scale(
                        scale: 0.5 + (_sparkleAnimation.value * 0.5),
                        child: Text(
                          sparkle,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _playSoundEffect() {
    // Play haptic feedback
    HapticFeedback.lightImpact();
    
    // TODO: Play sound effect based on widget.soundEffect
    // This would integrate with a sound service
  }
}

/// Magic Button with special animations and effects
class MagicButton extends StatefulWidget {
  final String text;
  final String? emoji;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isEnabled;

  const MagicButton({
    super.key,
    required this.text,
    this.emoji,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isEnabled = true,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _pressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pressAnimation, _glowAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: widget.isEnabled ? (_) => _pressController.forward() : null,
          onTapUp: widget.isEnabled ? (_) {
            _pressController.reverse();
            if (widget.onPressed != null) {
              HapticFeedback.mediumImpact();
              widget.onPressed!();
            }
          } : null,
          onTapCancel: widget.isEnabled ? () => _pressController.reverse() : null,
          child: Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                gradient: widget.backgroundColor != null 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor!,
                          widget.backgroundColor!.withOpacity(0.8),
                        ],
                      )
                    : MagicModeTheme.earthGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: MagicModeTheme.magicSuccess.withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: MagicModeTheme.magicAccent.withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.emoji != null) ...[
                      Text(
                        widget.emoji!,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
}

/// Magic Card with floating animation and glow effects
class MagicCard extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final bool isFloating;
  final VoidCallback? onTap;

  const MagicCard({
    super.key,
    required this.child,
    this.glowColor,
    this.isFloating = true,
    this.onTap,
  });

  @override
  State<MagicCard> createState() => _MagicCardState();
}

class _MagicCardState extends State<MagicCard>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isFloating) {
      _floatController.repeat(reverse: true);
    }
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _glowAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Transform.translate(
            offset: Offset(0, widget.isFloating ? _floatAnimation.value * 4 - 2 : 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.glowColor ?? MagicModeTheme.magicPrimary)
                        .withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: (widget.glowColor ?? MagicModeTheme.magicPrimary)
                        .withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: MagicModeTheme.magicCardGradient,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Magic Progress Bar with animated effects
class MagicProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final String? label;
  final String? emoji;

  const MagicProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.label,
    this.emoji,
  });

  @override
  State<MagicProgressBar> createState() => _MagicProgressBarState();
}

class _MagicProgressBarState extends State<MagicProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeOut),
    );

    _progressController.forward();
    
    // Trigger sparkle animation when progress completes
    if (widget.progress >= 1.0) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _sparkleController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(MagicProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _sparkleAnimation]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null || widget.emoji != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (widget.emoji != null) ...[
                      Text(
                        widget.emoji!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '${(_progressAnimation.value * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MagicModeTheme.magicPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.shade200,
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * _progressAnimation.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          widget.color ?? MagicModeTheme.magicPrimary,
                          (widget.color ?? MagicModeTheme.magicPrimary).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Sparkle effect when complete
                  if (_sparkleAnimation.value > 0 && widget.progress >= 1.0)
                    Positioned(
                      right: 0,
                      top: -4,
                      child: Opacity(
                        opacity: 1 - _sparkleAnimation.value,
                        child: Text(
                          '✨',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Magic Floating Action Button with special effects
class MagicFAB extends StatefulWidget {
  final String emoji;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const MagicFAB({
    super.key,
    required this.emoji,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  State<MagicFAB> createState() => _MagicFABState();
}

class _MagicFABState extends State<MagicFAB>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _bounceController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _rotateAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (widget.onPressed != null) {
              HapticFeedback.heavyImpact();
              widget.onPressed!();
            }
          },
          child: Transform.scale(
            scale: _bounceAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * 2 * math.pi,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.backgroundColor ?? MagicModeTheme.magicPrimary,
                      (widget.backgroundColor ?? MagicModeTheme.magicPrimary).withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? MagicModeTheme.magicPrimary).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 28),
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
