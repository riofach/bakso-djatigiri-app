// Usecase register
import 'auth_repository.dart';
import 'user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
    String role = 'kasir',
  }) {
    return repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }
}
