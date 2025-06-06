// BLoC khusus untuk operasi delete stock
// File ini berisi logika untuk delete stock bahan

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/delete_ingredient_usecase.dart';

// Event
abstract class DeleteStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteStockItemEvent extends DeleteStockEvent {
  final String id;

  DeleteStockItemEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// State
abstract class DeleteStockState extends Equatable {
  const DeleteStockState();

  @override
  List<Object?> get props => [];
}

class DeleteStockInitial extends DeleteStockState {}

class DeleteStockLoading extends DeleteStockState {}

class DeleteStockSuccess extends DeleteStockState {
  final String id;

  const DeleteStockSuccess(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteStockError extends DeleteStockState {
  final String message;

  const DeleteStockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class DeleteStockBloc extends Bloc<DeleteStockEvent, DeleteStockState> {
  final DeleteIngredientUseCase _deleteIngredientUseCase;

  DeleteStockBloc(this._deleteIngredientUseCase) : super(DeleteStockInitial()) {
    on<DeleteStockItemEvent>(_onDeleteStockItem);
  }

  Future<void> _onDeleteStockItem(
    DeleteStockItemEvent event,
    Emitter<DeleteStockState> emit,
  ) async {
    emit(DeleteStockLoading());

    try {
      await _deleteIngredientUseCase(event.id);
      emit(DeleteStockSuccess(event.id));
    } catch (e) {
      debugPrint('Error saat menghapus stock: $e');
      emit(DeleteStockError('Gagal menghapus stock: $e'));
    }
  }
}
