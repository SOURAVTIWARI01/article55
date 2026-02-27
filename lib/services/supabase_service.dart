import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

/// Supabase initialization and client access.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase. Call once at app startup.
  static Future<void> initialize() async {
    if (EnvConfig.demoMode) return; // Skip in demo mode

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }
}
