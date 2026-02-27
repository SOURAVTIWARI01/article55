import '../config/env_config.dart';
import '../models/candidate_model.dart';
import 'supabase_service.dart';

/// Service for candidate CRUD operations.
/// Supports both Supabase and demo mode.
class CandidateService {
  // ─── Demo Data ──────────────────────────────────────────────
  static final List<CandidateModel> _demoCandidates = [
    CandidateModel(
      id: 'cand-001',
      fullName: 'Rajesh Sharma',
      summary: 'Experienced community leader with 10 years of service. Focused on infrastructure and amenities improvement.',
      category: 'president',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
    CandidateModel(
      id: 'cand-002',
      fullName: 'Priya Mehta',
      summary: 'Advocate for transparency and digital governance. Aims to modernize society operations.',
      category: 'president',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
    CandidateModel(
      id: 'cand-003',
      fullName: 'Amit Patel',
      summary: 'Financial expert committed to reducing maintenance costs and improving fund allocation.',
      category: 'treasurer',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
    CandidateModel(
      id: 'cand-004',
      fullName: 'Sneha Gupta',
      summary: 'Chartered accountant with a plan for transparent financial reporting.',
      category: 'treasurer',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
    CandidateModel(
      id: 'cand-005',
      fullName: 'Vikram Singh',
      summary: 'Organized and detail-oriented. Plans to digitize all society records.',
      category: 'secretary',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
    CandidateModel(
      id: 'cand-006',
      fullName: 'Neha Kapoor',
      summary: 'Communication specialist focused on better resident engagement.',
      category: 'secretary',
      isApproved: true,
      createdAt: DateTime.now(),
    ),
  ];

  // ─── Fetch Approved Candidates ─────────────────────────────
  Future<List<CandidateModel>> fetchApprovedCandidates(String category) async {
    if (EnvConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _demoCandidates
          .where((c) => c.category == category && c.isApproved)
          .toList();
    }

    final data = await SupabaseService.client
        .from('candidates')
        .select()
        .eq('category', category)
        .eq('is_approved', true)
        .order('created_at');

    return (data as List).map((e) => CandidateModel.fromJson(e)).toList();
  }

  // ─── Fetch All Candidates (Admin) ──────────────────────────
  Future<List<CandidateModel>> fetchAllCandidates() async {
    if (EnvConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(_demoCandidates);
    }

    final data = await SupabaseService.client
        .from('candidates')
        .select()
        .order('created_at');

    return (data as List).map((e) => CandidateModel.fromJson(e)).toList();
  }

  // ─── Fetch Pending Candidates (Admin) ──────────────────────
  Future<List<CandidateModel>> fetchPendingCandidates() async {
    if (EnvConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _demoCandidates.where((c) => !c.isApproved).toList();
    }

    final data = await SupabaseService.client
        .from('candidates')
        .select()
        .eq('is_approved', false)
        .order('created_at');

    return (data as List).map((e) => CandidateModel.fromJson(e)).toList();
  }

  // ─── Create Candidate ──────────────────────────────────────
  Future<CandidateModel> createCandidate({
    required String fullName,
    required String summary,
    required String category,
    String? photoUrl,
    required String createdBy,
  }) async {
    if (EnvConfig.demoMode) {
      final candidate = CandidateModel(
        id: 'cand-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        summary: summary,
        photoUrl: photoUrl,
        category: category,
        isApproved: false,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );
      _demoCandidates.add(candidate);
      return candidate;
    }

    final insertData = {
      'full_name': fullName,
      'summary': summary,
      'photo_url': photoUrl,
      'category': category,
      'is_approved': false,
      'created_by': createdBy,
    };

    final data = await SupabaseService.client
        .from('candidates')
        .insert(insertData)
        .select()
        .single();

    return CandidateModel.fromJson(data);
  }

  // ─── Approve Candidate (Admin) ─────────────────────────────
  Future<void> approveCandidate(String candidateId) async {
    if (EnvConfig.demoMode) {
      final index = _demoCandidates.indexWhere((c) => c.id == candidateId);
      if (index != -1) {
        _demoCandidates[index] = _demoCandidates[index].copyWith(isApproved: true);
      }
      return;
    }

    await SupabaseService.client
        .from('candidates')
        .update({'is_approved': true})
        .eq('id', candidateId);
  }

  // ─── Reject / Delete Candidate (Admin) ─────────────────────
  Future<void> rejectCandidate(String candidateId) async {
    if (EnvConfig.demoMode) {
      _demoCandidates.removeWhere((c) => c.id == candidateId);
      return;
    }

    await SupabaseService.client
        .from('candidates')
        .delete()
        .eq('id', candidateId);
  }
}
