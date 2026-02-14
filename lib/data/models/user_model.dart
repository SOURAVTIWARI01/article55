class UserModel {
  final String id;
  final String name;
  final String blockNumber;
  final String flatNumber;
  final String phone;
  final String? email;
  final bool hasVoted;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.blockNumber,
    required this.flatNumber,
    required this.phone,
    this.email,
    this.hasVoted = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      blockNumber: json['block_number'] as String,
      flatNumber: json['flat_number'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      hasVoted: json['has_voted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'block_number': blockNumber,
      'flat_number': flatNumber,
      'phone': phone,
      'email': email,
      'has_voted': hasVoted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
