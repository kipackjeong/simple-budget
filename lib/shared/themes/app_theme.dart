import 'package:flutter/material.dart';

/// Application theme configuration based on minimalist design principles
class AppTheme {
  // Primary app colors
  /// Primary color used throughout the app - dark for high contrast
  static const Color primaryColor = Color(0xFF121212);

  /// Secondary color used for accents - vibrant for highlighting actions
  static const Color secondaryColor = Color.fromARGB(215, 20, 164, 203);

  /// Background color for light theme - subtle for minimal distraction
  static const Color bgColor = Color(0xFFF9F9F9);

  /// Background color for dark theme - deep black for immersive experience
  static const Color darkBgColor = Color(0xFF121212);

  /// Background color for cards and elevated surfaces
  static const Color cardColor = Colors.white;

  /// Dark theme card color
  static const Color darkCardColor = Color(0xFF1E1E1E);

  /// Color for positive values like income
  static const Color incomeColor = Color.fromARGB(255, 62, 187, 152);

  /// Color for negative values like expenses
  static const Color expenseColor = Color(0xFFFF5252);

  /// Accent color for highlighting important actions
  static const Color accentColor = Color(0xFFFF4081);

  /// Neutral color for text and icons
  static const Color neutralColor = Color(0xFF757575);

  /// Duration for standard animations (principle 7: Seamless Transitions)
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Curve for standard animations
  static const Curve animationCurve = Curves.easeInOut;

  /// Main theme data for the app - Light Theme
  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      error: expenseColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: bgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
      // Adding subtle shadow for depth (principle 2: Minimalist but focused)
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
      titleMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: primaryColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: neutralColor),
      labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
    ),
    // Card theme with subtle shadow for depth (principle 2: Minimalist but focused)
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    // Button theme with clear visual hierarchy (principle 2 & 8: Control and feedback)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Animation for feedback (principle 7: Seamless Transitions)
        animationDuration: animationDuration,
      ),
    ),
    // Text button theme for secondary actions
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        // Animation for feedback (principle 7)
        animationDuration: animationDuration,
      ),
    ),
    // Icon theme for consistent styling
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    // Bottom navigation with clear feedback on selection (principle 8)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: secondaryColor,
      unselectedItemColor: neutralColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
      // Label styling
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    // Page transitions for smooth navigation (principle 7)
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Snackbar theme for user feedback (principle 8)
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    // Dialog theme for user control (principle 8)
    dialogTheme: DialogTheme(
      backgroundColor: cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// Dark theme data for immersive experience (principle 2: Minimalist)
  static ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: secondaryColor,
      secondary: accentColor,
      surface: darkCardColor,
      error: expenseColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBgColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCardColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
      labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: const CardTheme(
      color: darkCardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        animationDuration: animationDuration,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: secondaryColor,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
