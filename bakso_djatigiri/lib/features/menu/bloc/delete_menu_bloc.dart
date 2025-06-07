// BLoC khusus untuk operasi delete menu
// File ini berisi logika untuk delete menu

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/delete_menu_usecase.dart';

// Event
abstract class DeleteMenuEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteMenuItemEvent extends DeleteMenuEvent {
  final String id;

  DeleteMenuItemEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// State
abstract class DeleteMenuState extends Equatable {
  const DeleteMenuState();

  @override
  List<Object?> get props => [];
}

class DeleteMenuInitial extends DeleteMenuState {}

class DeleteMenuLoading extends DeleteMenuState {}

class DeleteMenuSuccess extends DeleteMenuState {
  final String id;

  const DeleteMenuSuccess(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteMenuError extends DeleteMenuState {
  final String message;

  const DeleteMenuError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class DeleteMenuBloc extends Bloc<DeleteMenuEvent, DeleteMenuState> {
  final DeleteMenuUseCase _deleteMenuUseCase;

  DeleteMenuBloc(this._deleteMenuUseCase) : super(DeleteMenuInitial()) {
    on<DeleteMenuItemEvent>(_onDeleteMenuItem);
  }

  Future<void> _onDeleteMenuItem(
    DeleteMenuItemEvent event,
    Emitter<DeleteMenuState> emit,
  ) async {
    emit(DeleteMenuLoading());

    try {
      await _deleteMenuUseCase(event.id);
      emit(DeleteMenuSuccess(event.id));
    } catch (e) {
      debugPrint('Error saat menghapus menu: $e');
      emit(DeleteMenuError('Gagal menghapus menu: $e'));
    }
  }
}
