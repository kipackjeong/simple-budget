import 'package:flutter/material.dart';

/// Application theme configuration based on minimalist design principles
class AppTheme {
  // Primary app colors inspired by TikTok's high-contrast, vibrant look
  /// Primary color used throughout the app - deep blue for high contrast
  static const Color primaryColor = Color(0xFF0C1339);

  /// Secondary color used for accents - vibrant teal for highlighting actions
  static const Color secondaryColor = Color(0xFF00F2EA);

  /// Background color for light theme - clean white for minimal distraction
  static const Color bgColor = Color(0xFFF8F8F8);

  /// Background color for dark theme - true black for immersive experience 
  static const Color darkBgColor = Color(0xFF000000);

  /// Background color for cards and elevated surfaces in light theme
  static const Color cardColor = Colors.white;

  /// Dark theme card color with subtle contrast for visual hierarchy
  static const Color darkCardColor = Color(0xFF121212);

  /// Color for positive values like income - vibrant green
  static const Color incomeColor = Color(0xFF1DB954);

  /// Color for negative values like expenses - TikTok-inspired red
  static const Color expenseColor = Color(0xFFFF004F);

  /// Accent color for highlighting important actions - TikTok-inspired pink
  static const Color accentColor = Color(0xFFFF2C55);

  /// Neutral color for text and icons
  static const Color neutralColor = Color(0xFF8A8A8A);
  
  /// Gradient colors for visual appeal (TikTok-style graphics)
  static const List<Color> gradientColors = [Color(0xFF00F2EA), Color(0xFFFF2C55)];
  
  /// Surface variant color for subtle backgrounds
  static const Color surfaceVariant = Color(0xFF232323);

  /// Duration for standard animations (principle 7: Seamless Transitions)
  static const Duration animationDuration = Duration(milliseconds: 250);
  
  /// Duration for faster micro-interactions to feel responsive
  static const Duration microAnimationDuration = Duration(milliseconds: 150);
  
  /// Duration for page transitions to feel smooth like TikTok
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);

  /// Curve for standard animations - matches TikTok's fluid movement
  static const Curve animationCurve = Curves.easeOutCubic;
  
  /// Curve for micro-interactions that need to feel quick and responsive
  static const Curve microAnimationCurve = Curves.fastOutSlowIn;
  
  /// Curve for page transitions to match TikTok's fluid swipes
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

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
      surfaceVariant: Color(0xFFF0F0F0),
    ),
    scaffoldBackgroundColor: bgColor,
    // Modern, TikTok-inspired app bar (Principle 2: Minimalist and Focused)
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      elevation: 0,
      centerTitle: true, // TikTok-style centered title
      titleTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
      shadowColor: Colors.black.withOpacity(0.05),
      toolbarHeight: 56, // Slightly taller for better visual hierarchy
    ),
    // Typography matching TikTok's clean, legible style
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -0.5,
        height: 1.1, // Tighter line height for headlines
      ),
      displayMedium: TextStyle(
        fontSize: 28, 
        fontWeight: FontWeight.bold, 
        color: primaryColor,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22, 
        fontWeight: FontWeight.bold, 
        color: primaryColor,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: primaryColor,
        letterSpacing: -0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.normal, 
        color: primaryColor,
        height: 1.4, // Better readability
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.normal, 
        color: neutralColor,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: primaryColor,
        letterSpacing: 0.2, // Slightly wider spacing for labels
      ),
    ),
    // Card theme with subtle shadow for depth (Principle 2: Minimalist but focused)
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 1, // Lighter elevation for more subtle look
      shadowColor: Colors.black.withOpacity(0.08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)), // Slightly more rounded
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Built-in margins
    ),
    // Button theme with clear visual hierarchy (Principle 8: Control and feedback)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
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
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        animationDuration: microAnimationDuration,
      ),
    ),
    // Icon theme for consistent styling
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    // Bottom navigation with clear feedback on selection (Principle 3: Vertical Navigation)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: secondaryColor,
      unselectedItemColor: neutralColor,
      type: BottomNavigationBarType.fixed,
      elevation: 12, // More pronounced elevation
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 22),
      enableFeedback: true, // Haptic feedback
      // Label styling with animations
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    // Page transitions for smooth navigation (Principle 7: Seamless Transitions)
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(), // TikTok-style vertical transitions
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Snackbar theme for user feedback (Principle 8: User Control and Feedback)
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      actionTextColor: secondaryColor,
      // Animation configurations
      insetPadding: const EdgeInsets.all(16),
    ),
    // Dialog theme for user control (Principle 8: User Control and Feedback)
    dialogTheme: DialogTheme(
      backgroundColor: cardColor,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    // Input decoration for text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: secondaryColor, width: 1.5),
      ),
      // Label and hint styles
      labelStyle: const TextStyle(color: neutralColor),
      hintStyle: TextStyle(color: neutralColor.withOpacity(0.6)),
    ),
    // Divider theme for clean separators
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0F0F0),
      thickness: 1,
      space: 1,
    ),
    // Slider theme for interactive elements
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryColor,
      inactiveTrackColor: neutralColor.withOpacity(0.2),
      thumbColor: secondaryColor,
      overlayColor: secondaryColor.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),
    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return secondaryColor;
        }
        return null;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  /// Dark theme data for immersive experience (Principle 2: Minimalist)
  static ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: secondaryColor,
      secondary: accentColor,
      surface: darkCardColor,
      background: darkBgColor,
      error: expenseColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      surfaceVariant: surfaceVariant,
    ),
    scaffoldBackgroundColor: darkBgColor,
    // TikTok-style modern dark app bar 
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212), // Slightly lighter than background
      elevation: 0,
      centerTitle: true, // TikTok-style centered title
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      toolbarHeight: 56, // Slightly taller for better visual hierarchy
    ),
    // Dark mode typography with better contrast
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.1, // Tighter line height for headlines
      ),
      displayMedium: TextStyle(
        fontSize: 28, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.w600, 
        color: Colors.white,
        letterSpacing: -0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.normal, 
        color: Colors.white,
        height: 1.4, // Better readability
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.normal, 
        color: Colors.white70,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: Colors.white,
        letterSpacing: 0.2, // Slightly wider spacing for labels
      ),
    ),
    // Card theme with subtle glow for depth in dark mode
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 4,
      shadowColor: secondaryColor.withOpacity(0.1), // Subtle glow effect
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)), // Slightly more rounded
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Built-in margins
    ),
    // Button theme with vibrant accents for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black, // Dark text on bright button for contrast
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        animationDuration: animationDuration,
      ),
    ),
    // Text button theme for secondary actions in dark mode
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        animationDuration: microAnimationDuration,
      ),
    ),
    // Dark mode icons with glow effect
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 24,
      shadows: [
        Shadow(blurRadius: 4, color: secondaryColor.withOpacity(0.3)), // Subtle glow
      ],
    ),
    // Bottom navigation with vibrant indicators in dark mode
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: secondaryColor,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 16, // More pronounced elevation in dark mode
      selectedIconTheme: IconThemeData(
        size: 28, 
        shadows: [
          Shadow(blurRadius: 8, color: secondaryColor.withOpacity(0.5)),
        ],
      ),
      unselectedIconTheme: const IconThemeData(size: 22),
      enableFeedback: true, // Haptic feedback
      // Label styling with animations
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    // Page transitions for smooth navigation
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(), // TikTok-style vertical transitions
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Snackbar theme with vibrant accents for dark mode
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCardColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      actionTextColor: secondaryColor,
      // Animation configurations
      insetPadding: const EdgeInsets.all(16),
    ),
    // Dialog theme for dark mode
    dialogTheme: DialogTheme(
      backgroundColor: darkCardColor,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    // Input decoration for text fields in dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: secondaryColor, width: 1.5),
      ),
      // Label and hint styles
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
    ),
    // Divider theme for clean separators in dark mode
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    // Slider theme for interactive elements
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryColor,
      inactiveTrackColor: Colors.white.withOpacity(0.2),
      thumbColor: secondaryColor,
      overlayColor: secondaryColor.withOpacity(0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),
    // Checkbox theme for dark mode
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return secondaryColor;
        }
        return Colors.white.withOpacity(0.2);
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
