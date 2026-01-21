/// Admin User Model
/// Represents an admin user in the system
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  /// Create from JSON (for API response)
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'admin',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Create a copy with modifications
  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
