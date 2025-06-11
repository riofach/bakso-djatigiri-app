// UseCase untuk mendapatkan user yang sedang login
import '../entities/user.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserUseCase {
  final ProfileRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
