// BLoC untuk manajemen state profile
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/user.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_all_users_usecase.dart';
import '../domain/usecases/update_user_status_usecase.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class SignOutEvent extends ProfileEvent {}

class LoadAllUsersEvent extends ProfileEvent {}

class LoadAllUsersExceptCurrentEvent extends ProfileEvent {}

class UpdateUserStatusEvent extends ProfileEvent {
  final String userId;
  final bool isActive;

  const UpdateUserStatusEvent({
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, isActive];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class SignOutSuccess extends ProfileState {}

class AllUsersLoaded extends ProfileState {
  final List<User> users;

  const AllUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class StatusUpdateSuccess extends ProfileState {}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final UpdateUserStatusUseCase updateUserStatusUseCase;

  ProfileBloc({
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
    required this.getAllUsersUseCase,
    required this.updateUserStatusUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SignOutEvent>(_onSignOut);
    on<LoadAllUsersEvent>(_onLoadAllUsers);
    on<LoadAllUsersExceptCurrentEvent>(_onLoadAllUsersExceptCurrent);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('User not found or not logged in'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await signOutUseCase();
      emit(SignOutSuccess());
    } catch (e) {
      emit(ProfileError('Failed to sign out: $e'));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsersEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final users = await getAllUsersUseCase();
      emit(AllUsersLoaded(users));
    } catch (e) {
      emit(ProfileError('Failed to load users: $e'));
    }
  }

  Future<void> _onLoadAllUsersExceptCurrent(
    LoadAllUsersExceptCurrentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Mendapatkan user saat ini
      final currentUser = await getCurrentUserUseCase();
      if (currentUser == null) {
        emit(const ProfileError('User not found or not logged in'));
        return;
      }

      // Mendapatkan semua user
      final allUsers = await getAllUsersUseCase();

      // Filter user yang sedang login
      final filteredUsers =
          allUsers.where((user) => user.uid != currentUser.uid).toList();

      emit(AllUsersLoaded(filteredUsers));
    } catch (e) {
      emit(ProfileError('Failed to load users: $e'));
    }
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatusEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await updateUserStatusUseCase(event.userId, event.isActive);
      emit(StatusUpdateSuccess());
    } catch (e) {
      emit(ProfileError('Failed to update user status: $e'));
    }
  }
}
