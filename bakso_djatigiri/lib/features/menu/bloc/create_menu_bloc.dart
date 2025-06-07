// BLoC untuk fitur tambah menu
// ignore_for_file: unused_import
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../features/stock/domain/entities/ingredient_entity.dart';
import '../domain/entities/menu_requirement_entity.dart';
import '../domain/usecases/add_menu_usecase.dart';
import '../domain/usecases/calculate_menu_stock_usecase.dart';
import '../domain/usecases/get_ingredients_for_menu_usecase.dart';

// Event
abstract class CreateMenuEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends CreateMenuEvent {
  final String? imagePath; // local path
  PickImageEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class NameChangedEvent extends CreateMenuEvent {
  final String name;
  NameChangedEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class PriceChangedEvent extends CreateMenuEvent {
  final String price;
  PriceChangedEvent(this.price);
  @override
  List<Object?> get props => [price];
}

class LoadIngredientsEvent extends CreateMenuEvent {}

class AddIngredientRequirementEvent extends CreateMenuEvent {
  final String ingredientId;
  final String ingredientName;
  final int requiredAmount;

  AddIngredientRequirementEvent({
    required this.ingredientId,
    required this.ingredientName,
    required this.requiredAmount,
  });

  @override
  List<Object?> get props => [ingredientId, ingredientName, requiredAmount];
}

class RemoveIngredientRequirementEvent extends CreateMenuEvent {
  final String ingredientId;

  RemoveIngredientRequirementEvent(this.ingredientId);

  @override
  List<Object?> get props => [ingredientId];
}

class UpdateIngredientAmountEvent extends CreateMenuEvent {
  final String ingredientId;
  final int newAmount;

  UpdateIngredientAmountEvent({
    required this.ingredientId,
    required this.newAmount,
  });

  @override
  List<Object?> get props => [ingredientId, newAmount];
}

class SubmitMenuEvent extends CreateMenuEvent {}

// State
class CreateMenuState extends Equatable {
  final String? imagePath;
  final String? imageUrl;
  final String name;
  final String price;
  final List<IngredientEntity> availableIngredients;
  final List<MenuRequirementEntity> selectedRequirements;
  final bool isLoading;
  final bool isLoadingIngredients;
  final bool isSuccess;
  final String? error;

  const CreateMenuState({
    this.imagePath,
    this.imageUrl,
    this.name = '',
    this.price = '',
    this.availableIngredients = const [],
    this.selectedRequirements = const [],
    this.isLoading = false,
    this.isLoadingIngredients = false,
    this.isSuccess = false,
    this.error,
  });

  CreateMenuState copyWith({
    String? imagePath,
    String? imageUrl,
    String? name,
    String? price,
    List<IngredientEntity>? availableIngredients,
    List<MenuRequirementEntity>? selectedRequirements,
    bool? isLoading,
    bool? isLoadingIngredients,
    bool? isSuccess,
    String? error,
  }) {
    return CreateMenuState(
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      isLoading: isLoading ?? this.isLoading,
      isLoadingIngredients: isLoadingIngredients ?? this.isLoadingIngredients,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        imageUrl,
        name,
        price,
        availableIngredients,
        selectedRequirements,
        isLoading,
        isLoadingIngredients,
        isSuccess,
        error,
      ];
}

// Bloc
@injectable
class CreateMenuBloc extends Bloc<CreateMenuEvent, CreateMenuState> {
  final AddMenuUseCase _addMenuUseCase;
  final GetIngredientsForMenuUseCase _getIngredientsUseCase;
  final CalculateMenuStockUseCase _calculateMenuStockUseCase;

  CreateMenuBloc(
    this._addMenuUseCase,
    this._getIngredientsUseCase,
    this._calculateMenuStockUseCase,
  ) : super(const CreateMenuState()) {
    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(imagePath: event.imagePath, error: null));
    });

    on<NameChangedEvent>((event, emit) {
      emit(state.copyWith(name: event.name, error: null));
    });

    on<PriceChangedEvent>((event, emit) {
      emit(state.copyWith(price: event.price, error: null));
    });

    on<LoadIngredientsEvent>((event, emit) async {
      emit(state.copyWith(isLoadingIngredients: true, error: null));
      try {
        final ingredients = await _getIngredientsUseCase();
        emit(state.copyWith(
          availableIngredients: ingredients,
          isLoadingIngredients: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoadingIngredients: false,
          error: 'Gagal memuat data bahan: $e',
        ));
      }
    });

    on<AddIngredientRequirementEvent>((event, emit) {
      final requirements =
          List<MenuRequirementEntity>.from(state.selectedRequirements);

      // Cek apakah bahan sudah ada dalam requirements
      final existingIndex = requirements
          .indexWhere((req) => req.ingredientId == event.ingredientId);

      if (existingIndex >= 0) {
        // Update jumlah jika sudah ada
        final existing = requirements[existingIndex];
        requirements[existingIndex] = MenuRequirementEntity(
          id: existing.id,
          menuId: existing.menuId,
          ingredientId: existing.ingredientId,
          ingredientName: existing.ingredientName,
          requiredAmount: event.requiredAmount,
        );
      } else {
        // Tambahkan baru jika belum ada
        requirements.add(MenuRequirementEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuId: '',
          ingredientId: event.ingredientId,
          ingredientName: event.ingredientName,
          requiredAmount: event.requiredAmount,
        ));
      }

      emit(state.copyWith(selectedRequirements: requirements, error: null));
    });

    on<RemoveIngredientRequirementEvent>((event, emit) {
      final requirements =
          List<MenuRequirementEntity>.from(state.selectedRequirements)
            ..removeWhere((req) => req.ingredientId == event.ingredientId);

      emit(state.copyWith(selectedRequirements: requirements, error: null));
    });

    on<UpdateIngredientAmountEvent>((event, emit) {
      final requirements =
          List<MenuRequirementEntity>.from(state.selectedRequirements);
      final index = requirements
          .indexWhere((req) => req.ingredientId == event.ingredientId);

      if (index >= 0) {
        final existing = requirements[index];
        requirements[index] = MenuRequirementEntity(
          id: existing.id,
          menuId: existing.menuId,
          ingredientId: existing.ingredientId,
          ingredientName: existing.ingredientName,
          requiredAmount: event.newAmount,
        );

        emit(state.copyWith(selectedRequirements: requirements, error: null));
      }
    });

    on<SubmitMenuEvent>((event, emit) async {
      if (state.name.isEmpty ||
          state.price.isEmpty ||
          state.imagePath == null ||
          state.selectedRequirements.isEmpty) {
        emit(state.copyWith(
            error:
                'Semua field wajib diisi dan minimal 1 bahan harus dipilih'));
        return;
      }

      emit(state.copyWith(isLoading: true, error: null));

      try {
        final priceValue =
            int.tryParse(state.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        // Hitung stok menu berdasarkan ketersediaan bahan
        final stock = _calculateMenuStockUseCase(
          menuRequirements: state.selectedRequirements,
          availableIngredients: state.availableIngredients,
        );

        await _addMenuUseCase(
          name: state.name,
          price: priceValue,
          stock: stock, // Gunakan nilai stok yang dihitung
          imageFile: File(state.imagePath!),
          requirements: state.selectedRequirements,
        );

        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e'));
      }
    });
  }
}
