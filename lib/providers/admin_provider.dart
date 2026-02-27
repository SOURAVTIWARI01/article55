import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/candidate_service.dart';

/// State management for admin operations (candidate approval, stats).
class AdminProvider extends ChangeNotifier {
  final CandidateService _service = CandidateService();

  List<CandidateModel> _pendingCandidates = [];
  List<CandidateModel> _allCandidates = [];
  bool _isLoading = false;
  String? _error;

  List<CandidateModel> get pendingCandidates => _pendingCandidates;
  List<CandidateModel> get allCandidates => _allCandidates;
  int get pendingCount => _pendingCandidates.length;
  int get approvedCount => _allCandidates.where((c) => c.isApproved).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch pending candidates for approval.
  Future<void> fetchPending() async {
    _setLoading(true);
    try {
      _pendingCandidates = await _service.fetchPendingCandidates();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  /// Fetch all candidates (for stats etc.).
  Future<void> fetchAll() async {
    _setLoading(true);
    try {
      _allCandidates = await _service.fetchAllCandidates();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  /// Approve a candidate.
  Future<bool> approve(String candidateId) async {
    try {
      await _service.approveCandidate(candidateId);
      _pendingCandidates.removeWhere((c) => c.id == candidateId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Reject (delete) a candidate.
  Future<bool> reject(String candidateId) async {
    try {
      await _service.rejectCandidate(candidateId);
      _pendingCandidates.removeWhere((c) => c.id == candidateId);
      _allCandidates.removeWhere((c) => c.id == candidateId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
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
