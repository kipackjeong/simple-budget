import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/home_screen.dart';
import 'package:spending_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:spending_tracker/features/auth/presentation/screens/signup_screen.dart';
import 'package:spending_tracker/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:spending_tracker/features/auth/presentation/screens/update_password_screen.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Main entry point for the application
/// Entry point for the application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hoggwzqgireribjmbnpa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvZ2d3enFnaXJlcmliam1ibnBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NDU3NDYsImV4cCI6MjA2MjUyMTc0Nn0.Rdut5DuLOMnUmFHdyYcpXXdxVrwvQ6m9xV0QAkWgOHo',
    debug: true,
  );

  // Listen for deep link events - handles password reset links
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      // Handle password recovery event if needed
      debugPrint('Password recovery event received');
    }
  });

  // Set preferred device orientations for better UX (principle 5: Intuitive controls)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for a cleaner look (principle 2: Minimalist interface)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Run the application with Riverpod provider scope to enable state management
    runApp(const ProviderScope(child: SpendingTrackerApp()));
  } catch (err) {
    // Log error and show fallback UI if needed
    debugPrint('Error starting application: $err');
    // This would be where we'd implement error reporting/logging
  }
}

/// Provider for the app's theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Root application widget implementing UI/UX design principles
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple check for auth - we'll handle password reset through onGenerateRoute

    // Normal authentication flow
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}

class SpendingTrackerApp extends ConsumerWidget {
  /// Creates the application widget
  const SpendingTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode from the provider (dark/light theme switching)
    final themeMode = ref.watch(themeModeProvider);

    // Response from build method as per user rule #2
    final Widget res = MaterialApp(
      title: 'Spending Tracker',
      themeMode: themeMode,
      // Apply theme with animations for Principle 7: Seamless Transitions
      theme: AppTheme.themeData.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: AppTheme.darkThemeData,
      debugShowCheckedModeBanner: false,

      // Entry point to the app with immediate content display (principle 1)
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/password-reset': (context) => const PasswordResetScreen(),
        // Don't define update-password here because we need to handle the code parameter
        '/home': (context) => const HomeScreen(),
      },
      // Handle deep links for password reset
      onGenerateRoute: (settings) {
        debugPrint('Route requested: ${settings.name}');

        // Parse all potential deep links
        if (settings.name != null) {
          final uri = Uri.parse(settings.name!);
          final pathSegments = uri.pathSegments;
          final params = uri.queryParameters;

          // Special case for exact URL format http://localhost:8080/update-password?code=XXX
          if ((pathSegments.isNotEmpty &&
                  pathSegments.contains('update-password')) &&
              params.containsKey('code')) {
            debugPrint(
                '✅ Update password with code detected: ${params['code']}');
            return MaterialPageRoute(
              builder: (context) => UpdatePasswordScreen(token: params['code']),
              settings: settings,
            );
          }

          // Just update-password path
          if (pathSegments.isNotEmpty &&
              pathSegments.contains('update-password')) {
            debugPrint('⚠️ Update password route detected without code');
            return MaterialPageRoute(
              builder: (context) => const UpdatePasswordScreen(),
              settings: settings,
            );
          }

          // Root path but with code parameter
          if (pathSegments.isEmpty && params.containsKey('code')) {
            debugPrint('🔑 Auth code detected at root path: ${params['code']}');
            return MaterialPageRoute(
              builder: (context) => UpdatePasswordScreen(token: params['code']),
              settings: settings,
            );
          }

          // Legacy handlers
          if (pathSegments.isNotEmpty &&
              (pathSegments.contains('reset-callback') ||
                  pathSegments.contains('reset-password') ||
                  settings.name!.contains('type=recovery'))) {
            debugPrint('Password reset deep link detected: ${settings.name}');
            return MaterialPageRoute(
              builder: (context) =>
                  UpdatePasswordScreen(token: params['token']),
              settings: settings,
            );
          }

          // Check for auth actions generally
          if (params.containsKey('type') && params['type'] == 'recovery') {
            debugPrint('Recovery type detected in parameters');
            return MaterialPageRoute(
              builder: (context) => const UpdatePasswordScreen(),
              settings: settings,
            );
          }
        }

        return null;
      },
    );

    return res;
  }
}

/// Provider for tracking whether this is the first app launch
/// Used for Principle 1: Immediate Engagement
final isFirstLaunchProvider = StateProvider<bool>((ref) => true);
