import 'dart:async';
import '../config/env_config.dart';
import '../models/vote_model.dart';
import 'supabase_service.dart';

/// Service for voting operations with atomic vote casting.
/// Supports both Supabase (RPC) and demo mode.
class VotingService {
  // ─── Demo Data ──────────────────────────────────────────────
  static final List<VoteModel> _demoVotes = [];

  // ─── Cast Vote (Atomic) ────────────────────────────────────
  Future<void> castVote({
    required String userId,
    required String flatNumber,
    required String category,
    required String candidateId,
    String voteType = 'single',
  }) async {
    if (EnvConfig.demoMode) {
      return _demoCastVote(
        userId: userId,
        flatNumber: flatNumber,
        category: category,
        candidateId: candidateId,
        voteType: voteType,
      );
    }

    // Use RPC for atomic vote
    await SupabaseService.client.rpc('cast_vote', params: {
      'p_user_id': userId,
      'p_flat_number': flatNumber,
      'p_category': category,
      'p_candidate_id': candidateId,
      'p_vote_type': voteType,
    });
  }

  // ─── Check if Flat Already Voted ───────────────────────────
  Future<bool> hasVoted(String flatNumber, String category) async {
    if (EnvConfig.demoMode) {
      return _demoVotes.any(
        (v) => v.flatNumber == flatNumber && v.category == category,
      );
    }

    final data = await SupabaseService.client
        .from('votes')
        .select('id')
        .eq('flat_number', flatNumber)
        .eq('category', category)
        .maybeSingle();

    return data != null;
  }

  // ─── Get Voted Categories for a Flat ───────────────────────
  Future<Set<String>> getVotedCategories(String flatNumber) async {
    if (EnvConfig.demoMode) {
      return _demoVotes
          .where((v) => v.flatNumber == flatNumber)
          .map((v) => v.category)
          .toSet();
    }

    final data = await SupabaseService.client
        .from('votes')
        .select('category')
        .eq('flat_number', flatNumber);

    return (data as List).map((e) => e['category'] as String).toSet();
  }

  // ─── Get Vote Counts per Category ──────────────────────────
  Future<List<VoteCount>> getVoteCounts(String category) async {
    if (EnvConfig.demoMode) {
      return _demoGetVoteCounts(category);
    }

    final data = await SupabaseService.client
        .from('vote_counts')
        .select()
        .eq('category', category);

    return (data as List).map((e) => VoteCount.fromJson(e)).toList();
  }

  // ─── Get All Vote Counts ───────────────────────────────────
  Future<List<VoteCount>> getAllVoteCounts() async {
    if (EnvConfig.demoMode) {
      final categories = ['president', 'secretary', 'treasurer'];
      final List<VoteCount> all = [];
      for (final cat in categories) {
        all.addAll(_demoGetVoteCounts(cat));
      }
      return all;
    }

    final data = await SupabaseService.client.from('vote_counts').select();
    return (data as List).map((e) => VoteCount.fromJson(e)).toList();
  }

  // ─── Realtime Subscription ─────────────────────────────────
  StreamSubscription? subscribeToVotes(void Function() onVoteChange) {
    if (EnvConfig.demoMode) return null;

    return SupabaseService.client
        .from('votes')
        .stream(primaryKey: ['id'])
        .listen((_) => onVoteChange());
  }

  // ─── Demo Helpers ──────────────────────────────────────────
  void _demoCastVote({
    required String userId,
    required String flatNumber,
    required String category,
    required String candidateId,
    required String voteType,
  }) {
    // Check for duplicate (one vote per flat per category)
    final existing = _demoVotes.any(
      (v) => v.flatNumber == flatNumber && v.category == category,
    );
    if (existing) {
      throw Exception('Your flat has already voted in this category.');
    }

    _demoVotes.add(VoteModel(
      id: 'vote-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      flatNumber: flatNumber,
      category: category,
      candidateId: candidateId,
      voteType: voteType,
      createdAt: DateTime.now(),
    ));
  }

  List<VoteCount> _demoGetVoteCounts(String category) {
    final votesInCategory = _demoVotes.where((v) => v.category == category);
    final Map<String, int> counts = {};
    final Map<String, String> names = {};

    for (final v in votesInCategory) {
      counts[v.candidateId] = (counts[v.candidateId] ?? 0) + 1;
      names[v.candidateId] ??= v.candidateId; // placeholder
    }

    return counts.entries.map((e) => VoteCount(
      candidateId: e.key,
      candidateName: names[e.key] ?? '',
      category: category,
      totalVotes: e.value,
    )).toList();
  }
}
