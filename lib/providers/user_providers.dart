import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'service_providers.dart';

/// State class for user profile
class UserState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const UserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Whether the user is authenticated
  bool get isAuthenticated => user != null;
}

/// Notifier for handling user profile
class UserNotifier extends StateNotifier<UserState> {
  final UserService _service;

  UserNotifier(this._service) : super(const UserState());

  /// Fetch the current user profile
  Future<void> fetchCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final user = await _service.getCurrentUser();
      
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load user profile: ${err.toString()}',
      );
    }
  }

  /// Create new user profile after authentication
  Future<void> createUser(String email) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final user = await _service.createUser(email);
      
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create user profile: ${err.toString()}',
      );
    }
  }

  /// Clear user state (for sign out)
  void clearUser() {
    state = const UserState();
  }
}

/// Provider for user state notifier
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserNotifier(service);
});

/// Provider for authentication state
final authStateProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.isAuthenticated;
});
