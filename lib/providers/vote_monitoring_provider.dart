import 'package:flutter/material.dart';
import '../services/admin_service.dart';

/// State management for vote monitoring panel.
class VoteMonitoringProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<VoteRecord> _votes = [];
  String? _categoryFilter;
  String _flatSearch = '';
  bool _isLoading = false;
  String? _error;

  List<VoteRecord> get votes => _votes;
  String? get categoryFilter => _categoryFilter;
  String get flatSearch => _flatSearch;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _votes.length;

  /// Fetch all votes with current filters.
  Future<void> fetchVotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _votes = await _adminService.getAllVotes(
        category: _categoryFilter,
        flatSearch: _flatSearch.isNotEmpty ? _flatSearch : null,
      );
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set category filter and re-fetch.
  void setCategory(String? category) {
    _categoryFilter = category;
    fetchVotes();
  }

  /// Set flat search and re-fetch.
  void setFlatSearch(String search) {
    _flatSearch = search;
    fetchVotes();
  }

  /// Delete a suspicious vote.
  Future<bool> deleteVote(String voteId) async {
    try {
      await _adminService.deleteVote(voteId);
      _votes.removeWhere((v) => v.id == voteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
