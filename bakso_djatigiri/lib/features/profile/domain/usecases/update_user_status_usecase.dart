// UseCase untuk mengupdate status user (active/inactive)
import '../repositories/profile_repository.dart';

class UpdateUserStatusUseCase {
  final ProfileRepository repository;

  UpdateUserStatusUseCase(this.repository);

  Future<void> call(String userId, bool isActive) async {
    return await repository.updateUserStatus(userId, isActive);
  }
}
