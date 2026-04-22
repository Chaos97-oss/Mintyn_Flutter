class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String role; // e.g., 'UX/UI Designer'

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });
}
