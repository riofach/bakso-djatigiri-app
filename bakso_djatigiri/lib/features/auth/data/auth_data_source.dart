// Data source autentikasi ke Firebase Auth & Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

// Komentar: Custom exception untuk error autentikasi
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthDataSource({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists)
        throw AuthException('User tidak ditemukan di database');
      final data = userDoc.data()!;
      if (data['status'] != 'active')
        throw AuthException('Akun tidak aktif, silakan hubungi admin.');
      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email tidak terdaftar.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Password salah.');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Format email tidak valid.');
      } else {
        throw AuthException('Login gagal: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Terjadi kesalahan saat login.');
    }
  }

  Future<UserModel> register(
    String email,
    String password,
    String name, {
    String role = 'kasir',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        status: 'active',
      );
      await _firestore.collection('users').doc(userModel.uid).set({
        ...userModel.toMap(),
        'status': 'active',
      });
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw AuthException('Email sudah digunakan.');
      } else if (e.code == 'weak-password') {
        throw AuthException('Password terlalu lemah.');
      } else if (e.code == 'invalid-email') {
        throw AuthException('Format email tidak valid.');
      } else {
        throw AuthException('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Terjadi kesalahan saat registrasi.');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Gagal logout.');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;
    final data = userDoc.data()!;
    return UserModel.fromMap(data);
  }
}
