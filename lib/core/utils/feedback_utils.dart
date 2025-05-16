import 'package:flutter/material.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';

/// Utilities for providing user feedback and control
/// Implements Principle 8: User Control and Feedback
class FeedbackUtils {
  /// Shows a snackbar with a message at the TOP of the screen
  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Define colors based on feedback type
    final Color backgroundColor = _getBackgroundColor(type);
    final IconData icon = _getIcon(type);
    
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Create an overlay entry that appears at the top of the screen
    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (action != null)
                    TextButton(
                      onPressed: () {
                        overlayEntry?.remove();
                        action.onPressed();
                      },
                      child: Text(
                        action.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  InkWell(
                    onTap: () => overlayEntry?.remove(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    overlayState.insert(overlayEntry);
    
    // Auto-dismiss after duration
    if (duration != Duration.zero) {
      Future.delayed(duration, () {
        if (overlayEntry?.mounted ?? false) {
          overlayEntry?.remove();
        }
      });
    }
  }
  
  /// Shows a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          // Confirm button
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    // Return false if dialog was dismissed without a choice
    return res ?? false;
  }
  
  /// Shows a toast message that automatically disappears
  static void showToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
    
    // Add the overlay entry and remove after duration
    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
  
  /// Shows an action sheet with options
  static Future<T?> showActionSheet<T>(
    BuildContext context, {
    required String title,
    required List<ActionSheetOption<T>> options,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Options
            ...options.map((option) => ListTile(
              leading: Icon(option.icon),
              title: Text(option.title),
              onTap: () => Navigator.of(context).pop(option.value),
              textColor: option.isDangerous ? Colors.red : null,
              iconColor: option.isDangerous ? Colors.red : null,
            )),
            // Cancel button
            const SizedBox(height: 8),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Gets the background color based on snackbar type
  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppTheme.incomeColor;
      case SnackBarType.error:
        return AppTheme.expenseColor;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
      default:
        return AppTheme.primaryColor;
    }
  }
  
  /// Gets the icon based on snackbar type
  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
      default:
        return Icons.info;
    }
  }
}

/// Types of snackbar messages
enum SnackBarType {
  /// Informational message
  info,
  
  /// Success message
  success,
  
  /// Warning message
  warning,
  
  /// Error message
  error,
}

/// Option for action sheets
class ActionSheetOption<T> {
  /// Title of the option
  final String title;
  
  /// Icon for the option
  final IconData icon;
  
  /// Value to return when selected
  final T value;
  
  /// Whether this is a dangerous action (will be highlighted in red)
  final bool isDangerous;
  
  /// Creates an action sheet option
  const ActionSheetOption({
    required this.title,
    required this.icon,
    required this.value,
    this.isDangerous = false,
  });
}
