import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state management via Provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get userRole => _currentUser?.role ?? 'user';

  /// Sign in with phone and password.
  Future<bool> signIn(String phone, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signIn(phone, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Register a new user.
  Future<bool> register({
    required String name,
    required String blockNumber,
    required String flatNumber,
    required String phone,
    required String password,
    String? email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signUp(
        name: name,
        blockNumber: blockNumber,
        flatNumber: flatNumber,
        phone: phone,
        password: password,
        email: email,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Sign out and clear state.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
