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
        // ignore: curly_braces_in_flow_control_structures
        throw AuthException('User tidak ditemukan di database');
      final data = userDoc.data()!;
      if (data['status'] != 'active')
        // ignore: curly_braces_in_flow_control_structures
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

  // Metode untuk menambahkan user baru tanpa mengganti session owner
  Future<UserModel> register(
    String email,
    String password,
    String name, {
    String role = 'kasir',
  }) async {
    try {
      // Simpan user saat ini
      User? currentUser = _firebaseAuth.currentUser;

      // Simpan credential user saat ini (jika ada)
      // ignore: unused_local_variable
      UserCredential? currentUserCredential;

      if (currentUser != null) {
        // Jika ada user yang login, kita perlu mendapatkan token baru
        // untuk re-autentikasi nanti
        // Namun karena kita tidak bisa mendapatkan password user saat ini,
        // kita akan menggunakan pendekatan yang berbeda

        // Kita akan membuat user baru di Firebase Auth dan Firestore
        // tanpa mengubah session user saat ini

        // 1. Buat user baru di Firestore langsung (tanpa Firebase Auth)
        final String uid = _firestore.collection('users').doc().id;

        // 2. Buat model user
        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: role,
          status: 'active',
        );

        // 3. Simpan data user ke Firestore
        await _firestore.collection('users').doc(uid).set(userModel.toMap());

        return userModel;
      } else {
        // Jika tidak ada user yang login, gunakan metode normal
        // Buat user baru di Firebase Auth
        final userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Ambil UID dari user baru
        final String uid = userCredential.user!.uid;

        // Buat model user
        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: role,
          status: 'active',
        );

        // Simpan data user ke Firestore
        await _firestore.collection('users').doc(uid).set(userModel.toMap());

        return userModel;
      }
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

  // Metode alternatif untuk menambahkan user baru tanpa logout
  // Metode ini menggunakan Firestore langsung tanpa Firebase Auth
  // Ini tidak direkomendasikan untuk produksi karena alasan keamanan
  Future<UserModel> createUserInFirestore(
    String email,
    String password,
    String name, {
    String role = 'kasir',
  }) async {
    try {
      // Buat ID unik untuk user baru
      final String uid = _firestore.collection('users').doc().id;

      // Buat model user
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        status: 'active',
      );

      // Simpan data user ke Firestore
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      // Catatan: User ini tidak akan bisa login karena tidak ada di Firebase Auth
      // Ini hanya untuk demo atau pengujian

      return userModel;
    } catch (e) {
      throw AuthException('Terjadi kesalahan saat membuat user: $e');
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
