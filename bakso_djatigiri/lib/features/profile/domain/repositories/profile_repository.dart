// Repository interface untuk Profile
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart' as entity;

abstract class ProfileRepository {
  // Mendapatkan data user yang sedang login
  Future<entity.User?> getCurrentUser();

  // Sign out
  Future<void> signOut();

  // Mendapatkan stream perubahan auth state
  Stream<firebase_auth.User?> get authStateChanges;

  // Mendapatkan daftar user (hanya untuk owner)
  Future<List<entity.User>> getAllUsers();

  // Update status user (active/inactive)
  Future<void> updateUserStatus(String userId, bool isActive);
}
