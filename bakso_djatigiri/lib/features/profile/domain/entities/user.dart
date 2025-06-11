// Entity untuk User
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String status; // 'active' atau 'inactive'
  final String role; // 'owner' atau 'kasir'

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.status,
    required this.role,
  });

  bool get isOwner => role == 'owner';
  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [uid, name, email, status, role];
}
