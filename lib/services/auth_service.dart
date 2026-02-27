import '../config/env_config.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Authentication service wrapping Supabase auth + user data.
/// In demo mode, uses hardcoded credentials.
class AuthService {
  // ─── Demo Data ────────────────────────────────────────────
  static final List<UserModel> _demoUsers = [
    UserModel(
      id: 'user-001',
      name: 'Arpit',
      blockNumber: 'A',
      flatNumber: '101',
      phone: '9335946391',
      email: 'arpit@example.com',
      role: 'user',
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'admin-001',
      name: 'Admin',
      blockNumber: 'A',
      flatNumber: '001',
      phone: '8947043315',
      email: 'admin@article55.app',
      role: 'admin',
      createdAt: DateTime.now(),
    ),
  ];

  static final Map<String, String> _demoPasswords = {
    '9335946391': 'user@test',
    '8947043315': 'admin@test',
  };

  // ─── Sign In ──────────────────────────────────────────────
  Future<UserModel> signIn(String phone, String password) async {
    if (EnvConfig.demoMode) {
      return _demoSignIn(phone, password);
    }

    // Supabase: use phone-as-email pattern
    final email = '$phone@article55.app';
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed. Please check your credentials.');
    }

    // Fetch user profile from users table
    final data = await SupabaseService.client
        .from('users')
        .select()
        .eq('phone', phone)
        .single();

    return UserModel.fromJson(data);
  }

  // ─── Sign Up ──────────────────────────────────────────────
  Future<UserModel> signUp({
    required String name,
    required String blockNumber,
    required String flatNumber,
    required String phone,
    required String password,
    String? email,
  }) async {
    if (EnvConfig.demoMode) {
      return _demoSignUp(
        name: name,
        blockNumber: blockNumber,
        flatNumber: flatNumber,
        phone: phone,
        password: password,
        email: email,
      );
    }

    // Check uniqueness
    final existing = await SupabaseService.client
        .from('users')
        .select('id')
        .or('phone.eq.$phone,flat_number.eq.$flatNumber');

    if ((existing as List).isNotEmpty) {
      throw Exception('Phone number or flat number already registered.');
    }

    // Create auth user
    final authEmail = '$phone@article55.app';
    final authResponse = await SupabaseService.client.auth.signUp(
      email: authEmail,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    // Insert into users table
    final userData = {
      'id': authResponse.user!.id,
      'name': name,
      'block_number': blockNumber,
      'flat_number': flatNumber,
      'phone': phone,
      'email': email,
      'role': 'user',
    };

    await SupabaseService.client.from('users').insert(userData);

    return UserModel(
      id: authResponse.user!.id,
      name: name,
      blockNumber: blockNumber,
      flatNumber: flatNumber,
      phone: phone,
      email: email,
      role: 'user',
      createdAt: DateTime.now(),
    );
  }

  // ─── Sign Out ─────────────────────────────────────────────
  Future<void> signOut() async {
    if (!EnvConfig.demoMode) {
      await SupabaseService.client.auth.signOut();
    }
  }

  // ─── Demo Helpers ─────────────────────────────────────────
  UserModel _demoSignIn(String phone, String password) {
    final expectedPassword = _demoPasswords[phone];
    if (expectedPassword == null || expectedPassword != password) {
      throw Exception('Invalid credentials. Please try again.');
    }
    return _demoUsers.firstWhere((u) => u.phone == phone);
  }

  UserModel _demoSignUp({
    required String name,
    required String blockNumber,
    required String flatNumber,
    required String phone,
    required String password,
    String? email,
  }) {
    // Check if phone already exists
    if (_demoPasswords.containsKey(phone)) {
      throw Exception('Phone number already registered.');
    }
    // Check if flat already exists
    if (_demoUsers.any((u) => u.flatNumber == flatNumber)) {
      throw Exception('This flat number is already registered.');
    }

    final newUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      blockNumber: blockNumber,
      flatNumber: flatNumber,
      phone: phone,
      email: email,
      role: 'user',
      createdAt: DateTime.now(),
    );

    _demoUsers.add(newUser);
    _demoPasswords[phone] = password;
    return newUser;
  }
}
