// UseCase untuk sign out
import '../repositories/profile_repository.dart';

class SignOutUseCase {
  final ProfileRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}
