// BLoC untuk fitur edit stock bahan
// File ini berisi logika untuk edit dan delete stock bahan

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/ingredient_entity.dart';
import '../domain/usecases/get_ingredients_usecase.dart';
import '../domain/usecases/update_ingredient_usecase.dart';
import '../../../config/supabase_storage.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../features/menu/domain/usecases/update_all_menu_stocks_usecase.dart';

// Event
abstract class EditStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadIngredientEvent extends EditStockEvent {
  final String id;
  LoadIngredientEvent(this.id);
  @override
  List<Object?> get props => [id];
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

class SubmitEditEvent extends EditStockEvent {}

// State
class EditStockState extends Equatable {
  final String id;
  final String? imagePath; // Local path untuk file baru
  final String imageUrl; // URL untuk gambar yang sudah ada
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
@injectable
class EditStockBloc extends Bloc<EditStockEvent, EditStockState> {
  final GetIngredientsUseCase _getIngredientsUseCase;
  final UpdateIngredientUseCase _updateIngredientUseCase;
  final UpdateAllMenuStocksUseCase _updateAllMenuStocksUseCase;

  EditStockBloc(
    this._getIngredientsUseCase,
    this._updateIngredientUseCase,
    this._updateAllMenuStocksUseCase,
  ) : super(const EditStockState()) {
    on<LoadIngredientEvent>(_onLoadIngredient);
    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(imagePath: event.imagePath, error: null));
    });
    on<NameChangedEvent>((event, emit) {
      emit(state.copyWith(name: event.name, error: null));
    });
    on<AmountChangedEvent>((event, emit) {
      emit(state.copyWith(amount: event.amount, error: null));
    });
    on<SubmitEditEvent>(_onSubmitEdit);
  }

  Future<void> _onLoadIngredient(
    LoadIngredientEvent event,
    Emitter<EditStockState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final ingredients = await _getIngredientsUseCase();
      final ingredient = ingredients.firstWhere(
        (element) => element.id == event.id,
      );

      emit(
        state.copyWith(
          id: ingredient.id,
          name: ingredient.name,
          amount: ingredient.stockAmount.toString(),
          imageUrl: ingredient.imageUrl,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data bahan: $e',
      ));
    }
  }

  Future<void> _onSubmitEdit(
    SubmitEditEvent event,
    Emitter<EditStockState> emit,
  ) async {
    if (state.name.isEmpty || state.amount.isEmpty) {
      emit(state.copyWith(error: 'Nama dan jumlah wajib diisi'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Update stok bahan
      await _updateIngredientUseCase(
        id: state.id,
        name: state.name,
        stockAmount: int.tryParse(state.amount) ?? 0,
        imageFile: state.imagePath != null ? File(state.imagePath!) : null,
        currentImageUrl: state.imageUrl,
      );

      // Update stok semua menu yang menggunakan bahan ini
      final ingredients = await _getIngredientsUseCase();
      final updatedCount = await _updateAllMenuStocksUseCase(
        availableIngredients: ingredients,
      );

      debugPrint('Berhasil memperbarui stok $updatedCount menu');

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      debugPrint('Error updating stock: $e');
      emit(state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e'));
    }
  }

  // Future<void> _onDeleteStock(
  //   DeleteStockEvent event,
  //   Emitter<EditStockState> emit,
  // ) async {
  //   emit(state.copyWith(isLoading: true, error: null));

  //   try {
  //     // Hapus gambar dari Supabase Storage terlebih dahulu
  //     if (state.imageUrl.isNotEmpty) {
  //       await StorageHelper.deleteFileFromUrl(state.imageUrl);
  //     }

  //     // Hapus data dari Firestore
  //     await _firestore.collection('ingredients').doc(state.id).delete();

  //     emit(state.copyWith(
  //       isLoading: false,
  //       isDeleted: true,
  //     ));
  //   } catch (e) {
  //     debugPrint('Error saat menghapus stock: $e');
  //     emit(state.copyWith(
  //       isLoading: false,
  //       error: 'Gagal menghapus stock: $e',
  //     ));
  //   }
  // }

  Future<File?> _compressImage(String path) async {
    final file = File(path);
    return await ImageCompressor.compressImage(file);
  }

  Future<String?> _uploadImageToSupabase(String path) async {
    final file = File(path);
    return await SupabaseStorageService.uploadFile(file);
  }
}
