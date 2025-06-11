// Implementasi AuthRepository
import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/user_entity.dart';
import 'auth_data_source.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final user = await dataSource.login(email, password);
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      role: user.role,
      status: user.status,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    String role = 'kasir',
  }) async {
    final user = await dataSource.register(email, password, name, role: role);
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      role: user.role,
      status: user.status,
    );
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await dataSource.getCurrentUser();
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      role: user.role,
      status: user.status,
    );
  }
}
