/// Base Supabase service with common functionality
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService({SupabaseClient? supabaseClient}) 
    : client = supabaseClient ?? Supabase.instance.client;
    
  // Get the current authenticated user's ID
  String? get currentUserId => client.auth.currentUser?.id;
  
  // Check if a user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;
  
  // Get the database client 
  SupabaseClient get supabase => client;
}
