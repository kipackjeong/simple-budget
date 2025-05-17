import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import 'supabase_service.dart';

/// Service for user-related operations
class UserService extends SupabaseService {
  static const String _tableName = 'users';

  UserService({SupabaseClient? supabaseClient}) : super(supabaseClient: supabaseClient);

  /// Get the current logged in user
  Future<User?> getCurrentUser() async {
    if (!isAuthenticated) return null;
    
    try {
      final res = await supabase
          .from(_tableName)
          .select()
          .eq('id', currentUserId!)
          .single();
      
      return User.fromJson(res);
    } catch (err) {
      // Handle error or return null if user not found
      return null;
    }
  }

  /// Create a new user (typically called after auth signup)
  Future<User> createUser(String email) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to create profile');
    }
    
    try {
      final data = {
        'id': currentUserId,
        'email': email,
      };
      
      final res = await supabase
          .from(_tableName)
          .upsert(data)
          .select()
          .single();
      
      return User.fromJson(res);
    } catch (err) {
      throw Exception('Failed to create user: ${err.toString()}');
    }
  }
}
