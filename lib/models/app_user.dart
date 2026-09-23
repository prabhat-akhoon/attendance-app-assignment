import 'user_role.dart';

/// A logged-in account. For staff accounts, [staffId] links back to the
/// [Staff] profile this login represents.
class AppUser {
  final String id;
  final String username;
  final UserRole role;
  final String? staffId;

  const AppUser({
    required this.id,
    required this.username,
    required this.role,
    this.staffId,
  });

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      username: map['username'] as String,
      role: UserRole.fromDbValue(map['role'] as String),
      staffId: map['staff_id'] as String?,
    );
  }
}
