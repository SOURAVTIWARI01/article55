import 'package:flutter/material.dart';
import '../services/admin_service.dart';

/// State management for blocked flats and security actions.
class SecurityProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<BlockedFlat> _blockedFlats = [];
  bool _isLoading = false;
  String? _error;

  List<BlockedFlat> get blockedFlats => _blockedFlats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get blockedCount => _blockedFlats.length;

  /// Fetch all blocked flats.
  Future<void> fetchBlockedFlats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _blockedFlats = await _adminService.getBlockedFlats();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Block a flat.
  Future<bool> blockFlat(
      String flatNumber, String reason, String adminId) async {
    try {
      await _adminService.blockFlat(flatNumber, reason, adminId);
      await fetchBlockedFlats();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Unblock a flat.
  Future<bool> unblockFlat(String id) async {
    try {
      await _adminService.unblockFlat(id);
      _blockedFlats.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
