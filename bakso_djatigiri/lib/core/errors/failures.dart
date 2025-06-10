// Class abstrak Failure yang akan diextend oleh semua jenis failure
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Failure yang terjadi saat error pada server atau koneksi
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat tidak ada koneksi internet
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat error pada cache
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat data tidak ditemukan
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat validasi gagal
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat autentikasi gagal
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

// Failure yang terjadi saat stok tidak mencukupi
class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({required String message})
      : super(message: message);
}
