// Data source untuk mengakses data profile dari Firebase
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class ProfileDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Stream<firebase_auth.User?> get authStateChanges;
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserStatus(String userId, bool isActive);
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth auth;

  ProfileDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges => auth.authStateChanges();

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await firestore.collection('users').get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'status': isActive ? 'active' : 'inactive',
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }
}
