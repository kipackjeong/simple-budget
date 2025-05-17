import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/user_service.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';
import '../services/recurring_item_service.dart';

/// Provider for the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the base Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseService(supabaseClient: client);
});

/// Provider for user service
final userServiceProvider = Provider<UserService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserService(supabaseClient: client);
});

/// Provider for category service
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryService(supabaseClient: client);
});

/// Provider for transaction service
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TransactionService(supabaseClient: client);
});

/// Provider for budget service
final budgetServiceProvider = Provider<BudgetService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BudgetService(supabaseClient: client);
});

/// Provider for recurring item service
final recurringItemServiceProvider = Provider<RecurringItemService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RecurringItemService(supabaseClient: client);
});
