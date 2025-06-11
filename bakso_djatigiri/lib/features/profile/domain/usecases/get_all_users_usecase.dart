// UseCase untuk mendapatkan semua user (hanya untuk owner)
import '../entities/user.dart';
import '../repositories/profile_repository.dart';

class GetAllUsersUseCase {
  final ProfileRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<List<User>> call() async {
    return await repository.getAllUsers();
  }
}
