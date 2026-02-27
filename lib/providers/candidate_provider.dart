import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/candidate_service.dart';

/// State management for candidate operations.
class CandidateProvider extends ChangeNotifier {
  final CandidateService _service = CandidateService();

  List<CandidateModel> _candidates = [];
  bool _isLoading = false;
  String? _error;

  List<CandidateModel> get candidates => _candidates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch approved candidates for a category (user-facing).
  Future<void> fetchApproved(String category) async {
    _setLoading(true);
    try {
      _candidates = await _service.fetchApprovedCandidates(category);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  /// Create a new candidate (submitted by user, pending approval).
  Future<bool> createCandidate({
    required String fullName,
    required String summary,
    required String category,
    String? photoUrl,
    required String createdBy,
  }) async {
    _setLoading(true);
    try {
      await _service.createCandidate(
        fullName: fullName,
        summary: summary,
        category: category,
        photoUrl: photoUrl,
        createdBy: createdBy,
      );
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
