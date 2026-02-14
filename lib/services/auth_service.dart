import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Register a new user in the system
  Future<UserModel> registerUser({
    required String name,
    required String blockNumber,
    required String flatNumber,
    required String phone,
    String? email,
  }) async {
    try {
      // Check if phone number already exists
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Phone number already registered');
      }

      // Insert new user
      final response = await _supabase.from('users').insert({
        'name': name,
        'block_number': blockNumber,
        'flat_number': flatNumber,
        'phone': phone,
        'email': email,
      }).select().single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  /// Get user by phone number
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Check if a flat has already voted
  Future<bool> hasFlatVoted(String flatNumber) async {
    try {
      final response = await _supabase
          .from('users')
          .select('has_voted')
          .eq('flat_number', flatNumber)
          .eq('has_voted', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check voting status: $e');
    }
  }
}
