/// Candidate model matching the Supabase `candidates` table schema.
class CandidateModel {
  final String id;
  final String fullName;
  final String summary;
  final String? photoUrl;
  final String category; // 'president', 'secretary', 'treasurer'
  final bool isApproved;
  final String? createdBy;
  final DateTime createdAt;

  const CandidateModel({
    required this.id,
    required this.fullName,
    this.summary = '',
    this.photoUrl,
    required this.category,
    this.isApproved = false,
    this.createdBy,
    required this.createdAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      summary: json['summary'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      category: json['category'] as String,
      isApproved: json['is_approved'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'summary': summary,
      'photo_url': photoUrl,
      'category': category,
      'is_approved': isApproved,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// JSON for insert (let DB generate id and created_at).
  Map<String, dynamic> toInsertJson() {
    return {
      'full_name': fullName,
      'summary': summary,
      'photo_url': photoUrl,
      'category': category,
      'is_approved': false,
      'created_by': createdBy,
    };
  }

  CandidateModel copyWith({
    String? id,
    String? fullName,
    String? summary,
    String? photoUrl,
    String? category,
    bool? isApproved,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      summary: summary ?? this.summary,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      isApproved: isApproved ?? this.isApproved,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
