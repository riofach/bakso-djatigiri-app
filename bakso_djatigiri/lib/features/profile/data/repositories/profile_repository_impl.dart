// Implementasi repository untuk Profile
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart' as entity;
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<entity.User?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    return await dataSource.signOut();
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      dataSource.authStateChanges;

  @override
  Future<List<entity.User>> getAllUsers() async {
    return await dataSource.getAllUsers();
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    return await dataSource.updateUserStatus(userId, isActive);
  }
}
