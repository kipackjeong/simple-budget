import 'package:flutter/material.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';

/// Utilities for animations throughout the app
/// Implements Principle 7: Seamless Transitions and Animations
class AnimationUtils {
  /// Standard animation duration
  static const Duration duration = AppTheme.animationDuration;
  
  /// Standard animation curve
  static const Curve curve = AppTheme.animationCurve;
  
  /// Creates a fade transition for widgets
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  /// Creates a slide transition for widgets
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.fromBottom,
  }) {
    final Tween<Offset> tween = _getOffsetTween(direction);
    
    return SlideTransition(
      position: tween.animate(
        CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
      ),
      child: child,
    );
  }
  
  /// Creates a scale transition for widgets
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: animation,
      alignment: alignment,
      child: child,
    );
  }
  
  /// Combines fade and slide transitions
  static Widget fadeSlideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.fromBottom,
  }) {
    return fadeTransition(
      animation: animation,
      child: slideTransition(
        animation: animation,
        direction: direction,
        child: child,
      ),
    );
  }
  
  /// Helper to get offset tween based on slide direction
  static Tween<Offset> _getOffsetTween(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromTop:
        return Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero);
      case SlideDirection.fromBottom:
        return Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);
      case SlideDirection.fromLeft:
        return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
      case SlideDirection.fromRight:
        return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
    }
  }
}

/// Enum for slide directions
enum SlideDirection {
  /// Slide from top
  fromTop,
  
  /// Slide from bottom
  fromBottom,
  
  /// Slide from left
  fromLeft,
  
  /// Slide from right
  fromRight,
}

/// Extension for adding animations to widgets
extension AnimatedWidgetExtension on Widget {
  /// Wraps widget in a fade-in animation
  Widget fadeIn({
    Duration? duration,
    Curve? curve,
    bool delayed = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration ?? AnimationUtils.duration,
      curve: curve ?? AnimationUtils.curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: this,
    );
  }
  
  /// Wraps widget in a slide-in animation
  Widget slideIn({
    Duration? duration,
    Curve? curve,
    SlideDirection direction = SlideDirection.fromBottom,
    double distance = 100.0,
  }) {
    Offset beginOffset;
    
    // Set begin offset based on direction
    switch (direction) {
      case SlideDirection.fromTop:
        beginOffset = Offset(0, -distance);
        break;
      case SlideDirection.fromBottom:
        beginOffset = Offset(0, distance);
        break;
      case SlideDirection.fromLeft:
        beginOffset = Offset(-distance, 0);
        break;
      case SlideDirection.fromRight:
        beginOffset = Offset(distance, 0);
        break;
    }
    
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: beginOffset, end: Offset.zero),
      duration: duration ?? AnimationUtils.duration,
      curve: curve ?? AnimationUtils.curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: this,
    );
  }
  
  /// Wraps widget in a fade-and-slide-in animation
  Widget fadeSlideIn({
    Duration? duration,
    Curve? curve,
    SlideDirection direction = SlideDirection.fromBottom,
    double distance = 100.0,
  }) {
    return fadeIn(
      duration: duration,
      curve: curve,
    ).slideIn(
      duration: duration,
      curve: curve,
      direction: direction,
      distance: distance,
    );
  }
}
