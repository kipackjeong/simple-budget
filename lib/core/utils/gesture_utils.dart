import 'package:flutter/material.dart';

/// Utility class for intuitive gesture controls throughout the app.
class GestureUtils {
  /// Default swipe threshold distance in pixels
  static const double swipeThreshold = 50.0;
  
  /// Default swipe velocity threshold in pixels per second
  static const double swipeVelocityThreshold = 300.0;
  
  /// Creates a swipe detector widget that handles directional swipes
  /// Returns the child wrapped in a gesture detector
  static Widget swipeDetector({
    required Widget child,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeDown,
    double threshold = swipeThreshold,
    double velocityThreshold = swipeVelocityThreshold,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        try {
          if (details.primaryVelocity == null) return;
          
          final velocity = details.primaryVelocity!;
          
          // Detect right to left swipe (negative velocity)
          if (velocity < -velocityThreshold && onSwipeLeft != null) {
            onSwipeLeft();
          } 
          // Detect left to right swipe (positive velocity)
          else if (velocity > velocityThreshold && onSwipeRight != null) {
            onSwipeRight();
          }
        } catch (err) {
          debugPrint('Error in horizontal swipe detection: $err');
        }
      },
      onVerticalDragEnd: (details) {
        try {
          if (details.primaryVelocity == null) return;
          
          final velocity = details.primaryVelocity!;
          
          // Detect top to bottom swipe (positive velocity)
          if (velocity > velocityThreshold && onSwipeDown != null) {
            onSwipeDown();
          } 
          // Detect bottom to top swipe (negative velocity)
          else if (velocity < -velocityThreshold && onSwipeUp != null) {
            onSwipeUp();
          }
        } catch (err) {
          debugPrint('Error in vertical swipe detection: $err');
        }
      },
      child: child,
    );
  }
  
  /// Creates a widget that can be dismissed with a swipe (like in TikTok)
  /// Returns a dismissible widget with customizable direction and callbacks
  static Widget swipeToDismiss({
    required Widget child,
    required String key, 
    required DismissDirectionCallback onDismissed,
    DismissDirection direction = DismissDirection.horizontal,
    Widget? background,
    double threshold = swipeThreshold,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return Dismissible(
      key: Key(key),
      direction: direction,
      dismissThresholds: {direction: threshold / 100},
      onDismissed: onDismissed,
      background: background,
      child: child,
    );
  }
  
  /// Adds pull-to-refresh functionality to a widget
  /// Returns a refresh indicator with customizable callback
  static Widget pullToRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
    double displacement = 40.0,
    double edgeOffset = 0.0,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}

/// Extension for adding gesture detection to widgets
extension GestureDetectionExtension on Widget {
  /// Adds swipe detection to a widget
  Widget withSwipeDetection({
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeDown,
  }) {
    return GestureUtils.swipeDetector(
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      onSwipeUp: onSwipeUp,
      onSwipeDown: onSwipeDown,
      child: this,
    );
  }
  
  /// Adds pull-to-refresh functionality
  Widget withPullToRefresh({
    required Future<void> Function() onRefresh,
    Color? color,
  }) {
    return GestureUtils.pullToRefresh(
      onRefresh: onRefresh,
      color: color,
      child: this,
    );
  }
  
  /// Makes widget dismissible with swipe
  Widget withSwipeToDismiss({
    required String key,
    required DismissDirectionCallback onDismissed,
    DismissDirection direction = DismissDirection.horizontal,
    Widget? background,
  }) {
    return GestureUtils.swipeToDismiss(
      key: key,
      onDismissed: onDismissed,
      direction: direction,
      background: background,
      child: this,
    );
  }
}
