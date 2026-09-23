import '../data_sources/local/auth_local_data_source.dart';
import '../models/app_user.dart';

class AuthRepository {
  final AuthLocalDataSource _authLocalDataSource;

  AuthRepository(this._authLocalDataSource);

  /// Returns null on invalid credentials — dummy plaintext check, see
  /// CLAUDE.md "Auth (dummy, as the brief permits)".
  Future<AppUser?> login(String username, String password) async {
    final row = await _authLocalDataSource.getUserByUsername(username.trim());
    if (row == null) return null;
    if (row['password'] != password) return null;
    return AppUser.fromMap(row);
  }
}
