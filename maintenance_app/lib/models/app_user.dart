class AppUser {
  final int id;
  final String username;
  final String? fullName;
  final String role;
  final String? createdAt;
  final int active;

  AppUser({
    required this.id,
    required this.username,
    this.fullName,
    required this.role,
    this.createdAt,
    required this.active,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'],
      role: json['role'] ?? 'technician',
      createdAt: json['created_at'],
      active: json['active'] ?? 1,
    );
  }

  bool get isActive => active == 1;
}