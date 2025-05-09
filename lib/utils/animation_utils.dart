import 'package:flutter/material.dart';

/// Utility class for advanced animations in the MyDea app
class AnimationUtils {
  /// Creates a staggered animation sequence with multiple animations
  static AnimationController createStaggeredController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }
  
  /// Creates a pulse animation
  static Animation<double> createPulseAnimation({
    required AnimationController controller,
    double begin = 1.0,
    double end = 1.2,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Creates a fade-in animation
  static Animation<double> createFadeInAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeIn,
    double startInterval = 0.0,
    double endInterval = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }
  
  /// Creates a slide-in animation
  static Animation<Offset> createSlideInAnimation({
    required AnimationController controller,
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
    double startInterval = 0.0,
    double endInterval = 1.0,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }
  
  /// Creates a scale animation
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.elasticOut,
    double startInterval = 0.0,
    double endInterval = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }
  
  /// Creates a color animation
  static Animation<Color?> createColorAnimation({
    required AnimationController controller,
    required Color begin,
    required Color end,
    Curve curve = Curves.easeInOut,
    double startInterval = 0.0,
    double endInterval = 1.0,
  }) {
    return ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }
  
  /// Creates a shimmer effect animation
  static Animation<double> createShimmerAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Widget for creating staggered animations for child items
  static Widget staggeredList({
    required BuildContext context,
    required AnimationController controller,
    required List<Widget> children,
    double itemOffsetInterval = 0.1,
    Curve curve = Curves.easeOut,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: List.generate(
        children.length,
        (index) {
          final startInterval = index * itemOffsetInterval;
          final endInterval = startInterval + 0.6; // overlap animations
          
          return FadeTransition(
            opacity: createFadeInAnimation(
              controller: controller,
              startInterval: startInterval,
              endInterval: endInterval,
            ),
            child: SlideTransition(
              position: createSlideInAnimation(
                controller: controller,
                begin: const Offset(0.0, 0.2),
                startInterval: startInterval,
                endInterval: endInterval,
                curve: curve,
              ),
              child: children[index],
            ),
          );
        },
      ),
    );
  }
}