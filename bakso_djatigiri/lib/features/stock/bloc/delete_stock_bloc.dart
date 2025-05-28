// BLoC khusus untuk operasi delete stock
// File ini berisi logika untuk delete stock bahan

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/storage_helper.dart';

// Event
abstract class DeleteStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteStockItemEvent extends DeleteStockEvent {
  final String id;
  final String imageUrl;

  DeleteStockItemEvent({required this.id, required this.imageUrl});

  @override
  List<Object?> get props => [id, imageUrl];
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
class DeleteStockBloc extends Bloc<DeleteStockEvent, DeleteStockState> {
  final FirebaseFirestore _firestore;

  DeleteStockBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(DeleteStockInitial()) {
    on<DeleteStockItemEvent>(_onDeleteStockItem);
  }

  Future<void> _onDeleteStockItem(
    DeleteStockItemEvent event,
    Emitter<DeleteStockState> emit,
  ) async {
    emit(DeleteStockLoading());

    try {
      // Hapus gambar dari Supabase Storage terlebih dahulu
      if (event.imageUrl.isNotEmpty) {
        await StorageHelper.deleteFileFromUrl(event.imageUrl);
      }

      // Hapus data dari Firestore
      await _firestore.collection('ingredients').doc(event.id).delete();

      emit(DeleteStockSuccess(event.id));
    } catch (e) {
      debugPrint('Error saat menghapus stock: $e');
      emit(DeleteStockError('Gagal menghapus stock: $e'));
    }
  }
}
