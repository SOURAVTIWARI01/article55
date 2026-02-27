/// User model matching the Supabase `users` table schema.
class UserModel {
  final String id;
  final String name;
  final String blockNumber;
  final String flatNumber;
  final String phone;
  final String? email;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.blockNumber,
    required this.flatNumber,
    required this.phone,
    this.email,
    this.role = 'user',
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
      role: json['role'] as String? ?? 'user',
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
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// JSON for insert (without id and created_at, let DB generate them).
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'block_number': blockNumber,
      'flat_number': flatNumber,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? name,
    String? blockNumber,
    String? flatNumber,
    String? phone,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      blockNumber: blockNumber ?? this.blockNumber,
      flatNumber: flatNumber ?? this.flatNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
