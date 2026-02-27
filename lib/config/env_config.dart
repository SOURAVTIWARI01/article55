import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration – reads from .env file.
class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static bool get demoMode => (dotenv.env['DEMO_MODE'] ?? 'true') == 'true';
}
