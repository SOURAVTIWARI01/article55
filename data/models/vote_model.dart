class VoteModel {
  final String id;
  final String voterId;
  final String flatId;
  final String candidateId;
  final String post;
  final bool isUpvote;
  final DateTime timestamp;

  VoteModel({
    required this.id,
    required this.voterId,
    required this.flatId,
    required this.candidateId,
    required this.post,
    this.isUpvote = true,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voterId': voterId,
      'flatId': flatId,
      'candidateId': candidateId,
      'post': post,
      'isUpvote': isUpvote,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VoteModel.fromMap(Map<String, dynamic> map) {
    return VoteModel(
      id: map['id'] ?? '',
      voterId: map['voterId'] ?? '',
      flatId: map['flatId'] ?? '',
      candidateId: map['candidateId'] ?? '',
      post: map['post'] ?? '',
      isUpvote: map['isUpvote'] ?? true,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
