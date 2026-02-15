enum CandidateStatus { pending, approved, rejected }

class CandidateModel {
  final String id;
  final String name;
  final String post; // 'President', 'Secretary', 'Treasurer'
  final String summary;
  final String photoUrl;
  final CandidateStatus status;
  final int votesUp;
  final int votesDown;
  final DateTime createdAt;

  CandidateModel({
    required this.id,
    required this.name,
    required this.post,
    required this.summary,
    required this.photoUrl,
    this.status = CandidateStatus.pending,
    this.votesUp = 0,
    this.votesDown = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'post': post,
      'summary': summary,
      'photoUrl': photoUrl,
      'status': status.name,
      'votesUp': votesUp,
      'votesDown': votesDown,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    return CandidateModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      post: map['post'] ?? '',
      summary: map['summary'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      status: CandidateStatus.values.byName(map['status'] ?? 'pending'),
      votesUp: map['votesUp'] ?? 0,
      votesDown: map['votesDown'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
