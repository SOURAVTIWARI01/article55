class VoterModel {
  final String uid;
  final String name;
  final String blockNumber;
  final String flatNumber;
  final String phoneNumber;
  final String? email;
  final bool hasVoted;
  final String role; // 'voter', 'admin'
  final DateTime createdAt;

  VoterModel({
    required this.uid,
    required this.name,
    required this.blockNumber,
    required this.flatNumber,
    required this.phoneNumber,
    this.email,
    this.hasVoted = false,
    this.role = 'voter',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'blockNumber': blockNumber,
      'flatNumber': flatNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'hasVoted': hasVoted,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VoterModel.fromMap(Map<String, dynamic> map) {
    return VoterModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      blockNumber: map['blockNumber'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      hasVoted: map['hasVoted'] ?? false,
      role: map['role'] ?? 'voter',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String get flatId => '${blockNumber}_$flatNumber';
}
