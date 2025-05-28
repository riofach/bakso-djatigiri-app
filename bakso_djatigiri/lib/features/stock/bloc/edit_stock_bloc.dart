// BLoC untuk fitur edit stock bahan
// File ini berisi logika untuk edit dan delete stock bahan

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/supabase_storage.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_helper.dart';

// Event
abstract class EditStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStockEvent extends EditStockEvent {
  final String stockId;

  LoadStockEvent(this.stockId);

  @override
  List<Object?> get props => [stockId];
}

class PickImageEvent extends EditStockEvent {
  final String? imagePath; // local path

  PickImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class NameChangedEvent extends EditStockEvent {
  final String name;

  NameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class AmountChangedEvent extends EditStockEvent {
  final String amount;

  AmountChangedEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateStockEvent extends EditStockEvent {}

class DeleteStockEvent extends EditStockEvent {}

// State
class EditStockState extends Equatable {
  final String id;
  final String? imagePath; // local path jika ada perubahan gambar
  final String imageUrl; // URL gambar yang sudah ada
  final String name;
  final String amount;
  final bool isLoading;
  final bool isSuccess;
  final bool isDeleted;
  final String? error;

  const EditStockState({
    this.id = '',
    this.imagePath,
    this.imageUrl = '',
    this.name = '',
    this.amount = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.isDeleted = false,
    this.error,
  });

  EditStockState copyWith({
    String? id,
    String? imagePath,
    String? imageUrl,
    String? name,
    String? amount,
    bool? isLoading,
    bool? isSuccess,
    bool? isDeleted,
    String? error,
  }) {
    return EditStockState(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isDeleted: isDeleted ?? this.isDeleted,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imagePath,
        imageUrl,
        name,
        amount,
        isLoading,
        isSuccess,
        isDeleted,
        error,
      ];
}

// Bloc
class EditStockBloc extends Bloc<EditStockEvent, EditStockState> {
  final FirebaseFirestore _firestore;

  EditStockBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const EditStockState()) {
    on<LoadStockEvent>(_onLoadStock);
    on<PickImageEvent>(_onPickImage);
    on<NameChangedEvent>(_onNameChanged);
    on<AmountChangedEvent>(_onAmountChanged);
    on<UpdateStockEvent>(_onUpdateStock);
    on<DeleteStockEvent>(_onDeleteStock);
  }

  Future<void> _onLoadStock(
    LoadStockEvent event,
    Emitter<EditStockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final doc =
          await _firestore.collection('ingredients').doc(event.stockId).get();

      if (!doc.exists) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Stock tidak ditemukan',
        ));
        return;
      }

      final data = doc.data()!;

      emit(state.copyWith(
        id: doc.id,
        name: data['name'] ?? '',
        amount: (data['stock_amount'] ?? 0).toString(),
        imageUrl: data['image_url'] ?? '',
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data: $e',
      ));
    }
  }

  void _onPickImage(PickImageEvent event, Emitter<EditStockState> emit) {
    emit(state.copyWith(imagePath: event.imagePath, error: null));
  }

  void _onNameChanged(NameChangedEvent event, Emitter<EditStockState> emit) {
    emit(state.copyWith(name: event.name, error: null));
  }

  void _onAmountChanged(
      AmountChangedEvent event, Emitter<EditStockState> emit) {
    emit(state.copyWith(amount: event.amount, error: null));
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<EditStockState> emit,
  ) async {
    if (state.name.isEmpty || state.amount.isEmpty) {
      emit(state.copyWith(error: 'Nama dan jumlah stock wajib diisi'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      String imageUrl = state.imageUrl;

      // Jika ada perubahan gambar, upload gambar baru dan hapus gambar lama
      if (state.imagePath != null) {
        // Kompresi gambar terlebih dahulu
        final compressedFile = await _compressImage(state.imagePath!);
        if (compressedFile == null) {
          emit(state.copyWith(
            isLoading: false,
            error: 'Gagal mengkompresi gambar',
          ));
          return;
        }

        // Upload ke Supabase Storage
        final newImageUrl = await _uploadImageToSupabase(compressedFile.path);
        if (newImageUrl == null) {
          emit(state.copyWith(
            isLoading: false,
            error: 'Gagal upload gambar ke Supabase Storage',
          ));
          return;
        }

        // Hapus gambar lama dari Supabase Storage jika ada
        if (state.imageUrl.isNotEmpty) {
          await StorageHelper.deleteFileFromUrl(state.imageUrl);
        }

        imageUrl = newImageUrl;
      }

      // Update data di Firestore
      await _firestore.collection('ingredients').doc(state.id).update({
        'name': state.name,
        'stock_amount': int.tryParse(state.amount) ?? 0,
        'image_url': imageUrl,
        // Tidak update created_at karena ini edit
      });

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        imageUrl: imageUrl,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan saat update: $e',
      ));
    }
  }

  Future<void> _onDeleteStock(
    DeleteStockEvent event,
    Emitter<EditStockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Hapus gambar dari Supabase Storage terlebih dahulu
      if (state.imageUrl.isNotEmpty) {
        await StorageHelper.deleteFileFromUrl(state.imageUrl);
      }

      // Hapus data dari Firestore
      await _firestore.collection('ingredients').doc(state.id).delete();

      emit(state.copyWith(
        isLoading: false,
        isDeleted: true,
      ));
    } catch (e) {
      debugPrint('Error saat menghapus stock: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal menghapus stock: $e',
      ));
    }
  }

  Future<File?> _compressImage(String path) async {
    final file = File(path);
    return await ImageCompressor.compressImage(file);
  }

  Future<String?> _uploadImageToSupabase(String path) async {
    final file = File(path);
    return await SupabaseStorageService.uploadFile(file);
  }
}
