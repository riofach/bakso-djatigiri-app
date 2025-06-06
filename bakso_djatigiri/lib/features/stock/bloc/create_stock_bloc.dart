// BLoC untuk fitur tambah stock bahan
// ignore_for_file: unused_import
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/add_ingredient_usecase.dart';
import '../domain/usecases/get_ingredients_usecase.dart';
import '../../../features/menu/domain/usecases/update_all_menu_stocks_usecase.dart';

// Event
abstract class CreateStockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends CreateStockEvent {
  final String? imagePath; // local path
  PickImageEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class NameChangedEvent extends CreateStockEvent {
  final String name;
  NameChangedEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class AmountChangedEvent extends CreateStockEvent {
  final String amount;
  AmountChangedEvent(this.amount);
  @override
  List<Object?> get props => [amount];
}

class SubmitStockEvent extends CreateStockEvent {}

// State
class CreateStockState extends Equatable {
  final String? imagePath;
  final String? imageUrl;
  final String name;
  final String amount;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const CreateStockState({
    this.imagePath,
    this.imageUrl,
    this.name = '',
    this.amount = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  CreateStockState copyWith({
    String? imagePath,
    String? imageUrl,
    String? name,
    String? amount,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return CreateStockState(
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        imageUrl,
        name,
        amount,
        isLoading,
        isSuccess,
        error,
      ];
}

// Bloc
@injectable
class CreateStockBloc extends Bloc<CreateStockEvent, CreateStockState> {
  final AddIngredientUseCase _addIngredientUseCase;
  final GetIngredientsUseCase _getIngredientsUseCase;
  final UpdateAllMenuStocksUseCase _updateAllMenuStocksUseCase;

  CreateStockBloc(
    this._addIngredientUseCase,
    this._getIngredientsUseCase,
    this._updateAllMenuStocksUseCase,
  ) : super(const CreateStockState()) {
    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(imagePath: event.imagePath, error: null));
    });
    on<NameChangedEvent>((event, emit) {
      emit(state.copyWith(name: event.name, error: null));
    });
    on<AmountChangedEvent>((event, emit) {
      emit(state.copyWith(amount: event.amount, error: null));
    });
    on<SubmitStockEvent>((event, emit) async {
      if (state.name.isEmpty ||
          state.amount.isEmpty ||
          state.imagePath == null) {
        emit(state.copyWith(error: 'Semua field wajib diisi'));
        return;
      }
      emit(state.copyWith(isLoading: true, error: null));
      try {
        // Tambahkan bahan baru
        await _addIngredientUseCase(
          name: state.name,
          stockAmount: int.tryParse(state.amount) ?? 0,
          imageFile: File(state.imagePath!),
        );

        // Update stok semua menu yang mungkin menggunakan bahan ini
        final ingredients = await _getIngredientsUseCase();
        final updatedCount = await _updateAllMenuStocksUseCase(
          availableIngredients: ingredients,
        );

        debugPrint('Berhasil memperbarui stok $updatedCount menu');

        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e'));
      }
    });
  }
}
