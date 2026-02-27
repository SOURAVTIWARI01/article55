import 'dart:async';
import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/candidate_service.dart';
import '../services/voting_service.dart';

/// State management for voting operations and live results.
class VotingProvider extends ChangeNotifier {
  final VotingService _votingService = VotingService();
  final CandidateService _candidateService = CandidateService();

  // Candidates per category
  Map<String, List<CandidateModel>> _candidatesByCategory = {};
  // Vote counts per candidate
  Map<String, int> _voteCounts = {};
  // Categories the current flat has voted in
  Set<String> _votedCategories = {};

  bool _isLoading = false;
  String? _error;
  StreamSubscription? _realtimeSub;

  Map<String, List<CandidateModel>> get candidatesByCategory => _candidatesByCategory;
  Map<String, int> get voteCounts => _voteCounts;
  Set<String> get votedCategories => _votedCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool hasVotedIn(String category) => _votedCategories.contains(category);

  /// Load approved candidates for all categories + check voted status.
  Future<void> initialize(String flatNumber) async {
    _setLoading(true);
    try {
      final categories = ['president', 'secretary', 'treasurer'];
      final Map<String, List<CandidateModel>> result = {};

      for (final cat in categories) {
        result[cat] = await _candidateService.fetchApprovedCandidates(cat);
      }
      _candidatesByCategory = result;

      // Check which categories this flat has voted in
      _votedCategories = await _votingService.getVotedCategories(flatNumber);

      // Get current vote counts
      await _refreshVoteCounts();

      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _setLoading(false);
  }

  /// Cast a vote.
  Future<bool> castVote({
    required String userId,
    required String flatNumber,
    required String category,
    required String candidateId,
  }) async {
    _setLoading(true);
    try {
      await _votingService.castVote(
        userId: userId,
        flatNumber: flatNumber,
        category: category,
        candidateId: candidateId,
      );
      _votedCategories.add(category);
      await _refreshVoteCounts();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Refresh vote counts for all categories.
  Future<void> _refreshVoteCounts() async {
    final allCounts = await _votingService.getAllVoteCounts();
    _voteCounts = {};
    for (final vc in allCounts) {
      _voteCounts[vc.candidateId] = vc.totalVotes;
    }
  }

  /// Start realtime subscription for live updates.
  void startRealtimeUpdates() {
    _realtimeSub = _votingService.subscribeToVotes(() async {
      await _refreshVoteCounts();
      notifyListeners();
    });
  }

  int getVoteCount(String candidateId) => _voteCounts[candidateId] ?? 0;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }
}
