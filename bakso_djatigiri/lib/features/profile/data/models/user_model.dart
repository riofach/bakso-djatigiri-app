// Model untuk User di data layer
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as entity;

class UserModel extends entity.User {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.status,
    required super.role,
  });

  // Factory untuk membuat model dari Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      uid: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'inactive',
      role: data['role'] ?? 'kasir',
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'status': status,
      'role': role,
    };
  }
}
