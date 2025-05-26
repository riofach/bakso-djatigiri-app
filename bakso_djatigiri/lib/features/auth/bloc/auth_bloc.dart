// Bloc untuk autentikasi (login, register, logout)
// Pondasi state management fitur auth

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../auth/domain/auth_repository.dart';
import '../data/auth_data_source.dart';

// Event
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  RegisterEvent(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

class LogoutEvent extends AuthEvent {}

class CheckCurrentUserEvent extends AuthEvent {}

// State
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String uid;
  final String email;
  final String name;
  final String role;
  Authenticated(this.uid, this.email, this.name, this.role);
  @override
  List<Object?> get props => [uid, email, name, role];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.login(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(user.uid, user.email, user.name, user.role));
      } on AuthException catch (e) {
        emit(AuthError(e.message));
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError('Terjadi kesalahan tidak terduga.'));
        emit(Unauthenticated());
      }
    });
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.register(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        emit(Authenticated(user.uid, user.email, user.name, user.role));
      } on AuthException catch (e) {
        emit(AuthError(e.message));
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError('Terjadi kesalahan tidak terduga.'));
        emit(Unauthenticated());
      }
    });
    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.logout();
        emit(Unauthenticated());
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } catch (e) {
        emit(AuthError('Terjadi kesalahan tidak terduga.'));
      }
    });
    on<CheckCurrentUserEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.getCurrentUser();
        if (user == null) {
          emit(Unauthenticated());
        } else if (user.status == 'inactive') {
          emit(AuthError('Akun anda nonaktif, hubungi admin.'));
          emit(Unauthenticated());
        } else {
          emit(Authenticated(user.uid, user.email, user.name, user.role));
        }
      } catch (e) {
        emit(AuthError('Gagal memuat data user.'));
        emit(Unauthenticated());
      }
    });
  }
}
