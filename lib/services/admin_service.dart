import '../config/env_config.dart';
import 'supabase_service.dart';
import 'voting_service.dart';

/// Admin stats model for dashboard analytics.
class AdminStats {
  final int totalUsers;
  final int totalCandidates;
  final int totalVotes;
  final int presidentVotes;
  final int secretaryVotes;
  final int treasurerVotes;
  final int blockedFlats;
  final int pendingCandidates;

  const AdminStats({
    required this.totalUsers,
    required this.totalCandidates,
    required this.totalVotes,
    required this.presidentVotes,
    required this.secretaryVotes,
    required this.treasurerVotes,
    required this.blockedFlats,
    required this.pendingCandidates,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalCandidates: json['total_candidates'] ?? 0,
      totalVotes: json['total_votes'] ?? 0,
      presidentVotes: json['president_votes'] ?? 0,
      secretaryVotes: json['secretary_votes'] ?? 0,
      treasurerVotes: json['treasurer_votes'] ?? 0,
      blockedFlats: json['blocked_flats'] ?? 0,
      pendingCandidates: json['pending_candidates'] ?? 0,
    );
  }

  factory AdminStats.zero() => const AdminStats(
        totalUsers: 0,
        totalCandidates: 0,
        totalVotes: 0,
        presidentVotes: 0,
        secretaryVotes: 0,
        treasurerVotes: 0,
        blockedFlats: 0,
        pendingCandidates: 0,
      );

  double get turnoutPercent =>
      totalUsers > 0 ? (totalVotes / totalUsers * 100) : 0;
}

/// Vote record with joined user and candidate names.
class VoteRecord {
  final String id;
  final String userName;
  final String flatNumber;
  final String category;
  final String candidateName;
  final String voteType;
  final DateTime votedAt;

  const VoteRecord({
    required this.id,
    required this.userName,
    required this.flatNumber,
    required this.category,
    required this.candidateName,
    required this.voteType,
    required this.votedAt,
  });

  factory VoteRecord.fromJson(Map<String, dynamic> json) {
    return VoteRecord(
      id: json['vote_id'] ?? '',
      userName: json['user_name'] ?? '',
      flatNumber: json['flat_number'] ?? '',
      category: json['category'] ?? '',
      candidateName: json['candidate_name'] ?? '',
      voteType: json['vote_type'] ?? 'single',
      votedAt: DateTime.tryParse(json['voted_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Blocked flat model.
class BlockedFlat {
  final String id;
  final String flatNumber;
  final String reason;
  final String? blockedBy;
  final DateTime createdAt;

  const BlockedFlat({
    required this.id,
    required this.flatNumber,
    required this.reason,
    this.blockedBy,
    required this.createdAt,
  });

  factory BlockedFlat.fromJson(Map<String, dynamic> json) {
    return BlockedFlat(
      id: json['id'] ?? '',
      flatNumber: json['flat_number'] ?? '',
      reason: json['reason'] ?? '',
      blockedBy: json['blocked_by'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Service for admin-specific operations.
class AdminService {
  // ─── Demo Data ──────────────────────────────────────────────
  static final List<BlockedFlat> _demoBlockedFlats = [];

  // ─── Stats ──────────────────────────────────────────────────
  Future<AdminStats> getAdminStats() async {
    if (EnvConfig.demoMode) return _demoGetStats();

    final result = await SupabaseService.client.rpc('get_admin_stats');
    return AdminStats.fromJson(result as Map<String, dynamic>);
  }

  // ─── All Votes ──────────────────────────────────────────────
  Future<List<VoteRecord>> getAllVotes({
    String? category,
    String? flatSearch,
  }) async {
    if (EnvConfig.demoMode) return _demoGetAllVotes(category, flatSearch);

    final data = await SupabaseService.client.rpc('get_all_votes');
    List<VoteRecord> votes =
        (data as List).map((e) => VoteRecord.fromJson(e)).toList();

    if (category != null && category.isNotEmpty) {
      votes = votes.where((v) => v.category == category).toList();
    }
    if (flatSearch != null && flatSearch.isNotEmpty) {
      votes = votes
          .where((v) =>
              v.flatNumber.toLowerCase().contains(flatSearch.toLowerCase()))
          .toList();
    }
    return votes;
  }

  // ─── Delete Vote ────────────────────────────────────────────
  Future<void> deleteVote(String voteId) async {
    if (EnvConfig.demoMode) {
      VotingService.demoVotes.removeWhere((v) => v.id == voteId);
      return;
    }
    await SupabaseService.client.rpc('delete_vote', params: {
      'p_vote_id': voteId,
    });
  }

  // ─── Blocked Flats ──────────────────────────────────────────
  Future<List<BlockedFlat>> getBlockedFlats() async {
    if (EnvConfig.demoMode) return List.from(_demoBlockedFlats);

    final data = await SupabaseService.client
        .from('blocked_flats')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => BlockedFlat.fromJson(e)).toList();
  }

  Future<void> blockFlat(
      String flatNumber, String reason, String adminId) async {
    if (EnvConfig.demoMode) {
      if (_demoBlockedFlats.any((b) => b.flatNumber == flatNumber)) {
        throw Exception('Flat $flatNumber is already blocked.');
      }
      _demoBlockedFlats.add(BlockedFlat(
        id: 'block-${DateTime.now().millisecondsSinceEpoch}',
        flatNumber: flatNumber,
        reason: reason,
        blockedBy: adminId,
        createdAt: DateTime.now(),
      ));
      return;
    }

    await SupabaseService.client.from('blocked_flats').insert({
      'flat_number': flatNumber,
      'reason': reason,
      'blocked_by': adminId,
    });
  }

  Future<void> unblockFlat(String id) async {
    if (EnvConfig.demoMode) {
      _demoBlockedFlats.removeWhere((b) => b.id == id);
      return;
    }
    await SupabaseService.client.from('blocked_flats').delete().eq('id', id);
  }

  /// Check if a flat is blocked (used by voting service in demo mode).
  static bool isFlatBlocked(String flatNumber) {
    return _demoBlockedFlats.any((b) => b.flatNumber == flatNumber);
  }

  // ─── Demo Helpers ──────────────────────────────────────────
  AdminStats _demoGetStats() {
    final votes = VotingService.demoVotes;
    return AdminStats(
      totalUsers: 2,
      totalCandidates: 6,
      totalVotes: votes.length,
      presidentVotes: votes.where((v) => v.category == 'president').length,
      secretaryVotes: votes.where((v) => v.category == 'secretary').length,
      treasurerVotes: votes.where((v) => v.category == 'treasurer').length,
      blockedFlats: _demoBlockedFlats.length,
      pendingCandidates: 0,
    );
  }

  List<VoteRecord> _demoGetAllVotes(String? category, String? flatSearch) {
    var records = VotingService.demoVotes
        .map((v) => VoteRecord(
              id: v.id,
              userName: 'Voter (${v.flatNumber})',
              flatNumber: v.flatNumber,
              category: v.category,
              candidateName: 'Candidate',
              voteType: v.voteType,
              votedAt: v.createdAt,
            ))
        .toList();

    if (category != null && category.isNotEmpty) {
      records = records.where((v) => v.category == category).toList();
    }
    if (flatSearch != null && flatSearch.isNotEmpty) {
      records = records
          .where((v) =>
              v.flatNumber.toLowerCase().contains(flatSearch.toLowerCase()))
          .toList();
    }
    return records;
  }
}
