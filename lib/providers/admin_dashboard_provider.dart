import 'package:flutter/material.dart';
import '../services/admin_service.dart';

/// State management for admin dashboard analytics.
class AdminDashboardProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  AdminStats _stats = AdminStats.zero();
  bool _isLoading = false;
  String? _error;

  AdminStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch live stats from backend.
  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _adminService.getAdminStats();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh stats (called after admin actions).
  Future<void> refresh() => fetchStats();
}
