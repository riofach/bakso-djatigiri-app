// Entity User untuk domain autentikasi
class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String status;

  UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
  });
}
