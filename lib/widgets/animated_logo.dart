import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLogo extends StatefulWidget {
  final double size;
  final double glowIntensity;
  final bool animateGlow;
  
  const AnimatedLogo({
    Key? key,
    this.size = 240,
    this.glowIntensity = 0.8,
    this.animateGlow = true,
  }) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clean, simple white ring
              Container(
                width: widget.size * 1.1,
                height: widget.size * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4 + (0.1 * value)),
                    width: 2.0,
                  ),
                ),
              ),
              
              // Logo image with pulse - absolutely no overlay or effects
              Transform.scale(
                scale: 1.0 + (0.05 * value),
                child: Image.asset(
                  'assets/images/mydea-logo.png',
                  width: widget.size * 0.8,
                  height: widget.size * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  
  const ShimmerEffect({Key? key, required this.child}) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        // Calculate animated alignments instead of using GradientRotation
        final double value = _shimmerController.value;
        final Alignment begin = Alignment(
          -0.5 + value * 2.0,
          -0.5 + value * 2.0,
        );
        final Alignment end = Alignment(
          0.5 + value * 0.5,
          0.5 + value * 0.5,
        );
        
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.5),
                AppTheme.secondaryColor.withOpacity(0.5),
                AppTheme.tertiaryColor.withOpacity(0.5),
                AppTheme.primaryColor.withOpacity(0.5),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
              begin: begin,
              end: end,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}