class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'Active',
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: (json['role'] as String? ?? 'operator').toLowerCase(),
      status: json['status'] as String? ?? 'Active',
      lastLogin: json['lastLogin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'lastLogin': lastLogin,
    };
  }
}
