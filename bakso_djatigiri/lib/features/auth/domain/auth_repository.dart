// Repository abstrak untuk autentikasi
import 'user_entity.dart';

abstract class AuthRepository {
  /// Semua method dapat melempar [AuthException] jika terjadi error autentikasi
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String role = 'kasir',
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
