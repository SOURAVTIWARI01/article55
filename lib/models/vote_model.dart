/// Vote model matching the Supabase `votes` table schema.
class VoteModel {
  final String id;
  final String userId;
  final String flatNumber;
  final String category;
  final String candidateId;
  final String voteType; // 'single', 'upvote', 'downvote'
  final DateTime createdAt;

  const VoteModel({
    required this.id,
    required this.userId,
    required this.flatNumber,
    required this.category,
    required this.candidateId,
    this.voteType = 'single',
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      flatNumber: json['flat_number'] as String,
      category: json['category'] as String,
      candidateId: json['candidate_id'] as String,
      voteType: json['vote_type'] as String? ?? 'single',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'flat_number': flatNumber,
      'category': category,
      'candidate_id': candidateId,
      'vote_type': voteType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Aggregated vote count per candidate (from view or query).
class VoteCount {
  final String candidateId;
  final String candidateName;
  final String category;
  final int totalVotes;

  const VoteCount({
    required this.candidateId,
    required this.candidateName,
    required this.category,
    required this.totalVotes,
  });

  factory VoteCount.fromJson(Map<String, dynamic> json) {
    return VoteCount(
      candidateId: json['candidate_id'] as String,
      candidateName: json['candidate_name'] as String,
      category: json['category'] as String,
      totalVotes: (json['total_votes'] as num?)?.toInt() ?? 0,
    );
  }
}
