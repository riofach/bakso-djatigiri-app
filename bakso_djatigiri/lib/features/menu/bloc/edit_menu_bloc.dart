// BLoC untuk fitur edit menu
// File ini berisi logika untuk edit menu

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/menu_entity.dart';
import '../domain/entities/menu_requirement_entity.dart';
import '../../../features/stock/domain/entities/ingredient_entity.dart';
import '../domain/usecases/get_menu_usecase.dart';
import '../domain/usecases/update_menu_usecase.dart';
import '../domain/usecases/get_menu_requirements_usecase.dart';
import '../domain/usecases/get_ingredients_for_menu_usecase.dart';
import '../domain/usecases/update_menu_requirements_usecase.dart';
import '../domain/usecases/delete_menu_usecase.dart';
import '../domain/usecases/update_menu_stock_usecase.dart';
import '../../../config/supabase_storage.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_helper.dart';

// Event
abstract class EditMenuEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends EditMenuEvent {
  final String id;
  LoadMenuEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadMenuRequirementsEvent extends EditMenuEvent {
  final String menuId;
  LoadMenuRequirementsEvent(this.menuId);
  @override
  List<Object?> get props => [menuId];
}

class PickImageEvent extends EditMenuEvent {
  final String? imagePath; // local path
  PickImageEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class NameChangedEvent extends EditMenuEvent {
  final String name;
  NameChangedEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class PriceChangedEvent extends EditMenuEvent {
  final String price;
  PriceChangedEvent(this.price);
  @override
  List<Object?> get props => [price];
}

class AddIngredientRequirementEvent extends EditMenuEvent {
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

class RemoveIngredientRequirementEvent extends EditMenuEvent {
  final String ingredientId;

  RemoveIngredientRequirementEvent(this.ingredientId);

  @override
  List<Object?> get props => [ingredientId];
}

class UpdateIngredientAmountEvent extends EditMenuEvent {
  final String ingredientId;
  final int newAmount;

  UpdateIngredientAmountEvent({
    required this.ingredientId,
    required this.newAmount,
  });

  @override
  List<Object?> get props => [ingredientId, newAmount];
}

class SubmitEditEvent extends EditMenuEvent {}

class DeleteMenuEvent extends EditMenuEvent {}

// State
class EditMenuState extends Equatable {
  final String id;
  final String? imagePath; // Local path untuk file baru
  final String imageUrl; // URL untuk gambar yang sudah ada
  final String name;
  final String price;
  final int stock;
  final List<IngredientEntity> availableIngredients;
  final List<MenuRequirementEntity> selectedRequirements;
  final bool isLoading;
  final bool isLoadingIngredients;
  final bool isSuccess;
  final bool isDeleted;
  final String? error;

  const EditMenuState({
    this.id = '',
    this.imagePath,
    this.imageUrl = '',
    this.name = '',
    this.price = '',
    this.stock = 0,
    this.availableIngredients = const [],
    this.selectedRequirements = const [],
    this.isLoading = false,
    this.isLoadingIngredients = false,
    this.isSuccess = false,
    this.isDeleted = false,
    this.error,
  });

  EditMenuState copyWith({
    String? id,
    String? imagePath,
    String? imageUrl,
    String? name,
    String? price,
    int? stock,
    List<IngredientEntity>? availableIngredients,
    List<MenuRequirementEntity>? selectedRequirements,
    bool? isLoading,
    bool? isLoadingIngredients,
    bool? isSuccess,
    bool? isDeleted,
    String? error,
  }) {
    return EditMenuState(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      availableIngredients: availableIngredients ?? this.availableIngredients,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      isLoading: isLoading ?? this.isLoading,
      isLoadingIngredients: isLoadingIngredients ?? this.isLoadingIngredients,
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
        price,
        stock,
        availableIngredients,
        selectedRequirements,
        isLoading,
        isLoadingIngredients,
        isSuccess,
        isDeleted,
        error,
      ];
}

// Bloc
@injectable
class EditMenuBloc extends Bloc<EditMenuEvent, EditMenuState> {
  final GetMenuUseCase _getMenuUseCase;
  final UpdateMenuUseCase _updateMenuUseCase;
  final GetMenuRequirementsUseCase _getMenuRequirementsUseCase;
  final GetIngredientsForMenuUseCase _getIngredientsUseCase;
  final UpdateMenuRequirementsUseCase _updateMenuRequirementsUseCase;
  final DeleteMenuUseCase _deleteMenuUseCase;
  final UpdateMenuStockUseCase _updateMenuStockUseCase;

  EditMenuBloc(
    this._getMenuUseCase,
    this._updateMenuUseCase,
    this._getMenuRequirementsUseCase,
    this._getIngredientsUseCase,
    this._updateMenuRequirementsUseCase,
    this._deleteMenuUseCase,
    this._updateMenuStockUseCase,
  ) : super(const EditMenuState()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<LoadMenuRequirementsEvent>(_onLoadMenuRequirements);
    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(imagePath: event.imagePath, error: null));
    });
    on<NameChangedEvent>((event, emit) {
      emit(state.copyWith(name: event.name, error: null));
    });
    on<PriceChangedEvent>((event, emit) {
      emit(state.copyWith(price: event.price, error: null));
    });
    on<AddIngredientRequirementEvent>(_onAddIngredientRequirement);
    on<RemoveIngredientRequirementEvent>(_onRemoveIngredientRequirement);
    on<UpdateIngredientAmountEvent>(_onUpdateIngredientAmount);
    on<SubmitEditEvent>(_onSubmitEdit);
    on<DeleteMenuEvent>(_onDeleteMenu);
  }

  Future<void> _onLoadMenu(
    LoadMenuEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      debugPrint('EditMenuBloc: Loading menu with ID: ${event.id}');
      final menu = await _getMenuUseCase(event.id);
      debugPrint('EditMenuBloc: Menu loaded successfully: ${menu.name}');

      emit(
        state.copyWith(
          id: menu.id,
          name: menu.name,
          price: 'Rp ${menu.price}',
          stock: menu.stock,
          imageUrl: menu.imageUrl,
          isLoading: false,
        ),
      );

      // Load menu requirements setelah data menu didapatkan
      debugPrint('EditMenuBloc: Triggering load menu requirements');
      add(LoadMenuRequirementsEvent(menu.id));
    } catch (e) {
      debugPrint('EditMenuBloc: Error loading menu: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data menu: $e',
      ));
    }
  }

  Future<void> _onLoadMenuRequirements(
    LoadMenuRequirementsEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    emit(state.copyWith(isLoadingIngredients: true, error: null));
    try {
      debugPrint(
          'Fetching ingredients and menu requirements for menu ID: ${event.menuId}');

      // Fetch semua bahan yang tersedia
      final availableIngredients = await _getIngredientsUseCase();
      debugPrint('Available ingredients count: ${availableIngredients.length}');

      // Fetch menu requirements untuk menu ini
      final requirements = await _getMenuRequirementsUseCase(event.menuId);
      debugPrint('Menu requirements count: ${requirements.length}');

      emit(state.copyWith(
        availableIngredients: availableIngredients,
        selectedRequirements: requirements,
        isLoadingIngredients: false,
      ));
    } catch (e) {
      debugPrint('Error fetching ingredients or menu requirements: $e');
      emit(state.copyWith(
        isLoadingIngredients: false,
        error: 'Gagal memuat data bahan: $e',
      ));
    }
  }

  Future<void> _onAddIngredientRequirement(
    AddIngredientRequirementEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    try {
      debugPrint(
          'Adding ingredient requirement: ${event.ingredientName} (${event.ingredientId}) - ${event.requiredAmount}');

      // Create a new ingredient requirement
      final newRequirement = MenuRequirementEntity(
        id: '', // Will be generated later during save
        menuId: state.id,
        ingredientId: event.ingredientId,
        ingredientName: event.ingredientName,
        requiredAmount: event.requiredAmount,
      );

      // Add to the current state's requirements list
      final updatedRequirements =
          List<MenuRequirementEntity>.from(state.selectedRequirements)
            ..add(newRequirement);

      debugPrint(
          'Total requirements after adding: ${updatedRequirements.length}');

      // Hitung stock baru dan update state
      final newStock = await _calculateAndUpdateStock(
        updatedRequirements,
        state.availableIngredients,
      );

      emit(state.copyWith(
        selectedRequirements: updatedRequirements,
        stock: newStock,
      ));
    } catch (e) {
      debugPrint('Error adding ingredient requirement: $e');
      emit(state.copyWith(error: 'Gagal menambahkan bahan: $e'));
    }
  }

  Future<void> _onRemoveIngredientRequirement(
    RemoveIngredientRequirementEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    try {
      debugPrint(
          'Removing ingredient requirement with id: ${event.ingredientId}');

      // Remove from the current state's requirements list
      final updatedRequirements = state.selectedRequirements
          .where((req) => req.ingredientId != event.ingredientId)
          .toList();

      debugPrint(
          'Total requirements after removing: ${updatedRequirements.length}');

      // Hitung stock baru dan update state
      final newStock = await _calculateAndUpdateStock(
        updatedRequirements,
        state.availableIngredients,
      );

      emit(state.copyWith(
        selectedRequirements: updatedRequirements,
        stock: newStock,
      ));
    } catch (e) {
      debugPrint('Error removing ingredient requirement: $e');
      emit(state.copyWith(error: 'Gagal menghapus bahan: $e'));
    }
  }

  Future<void> _onUpdateIngredientAmount(
    UpdateIngredientAmountEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    try {
      debugPrint(
          'Updating ingredient amount: ${event.ingredientId} - ${event.newAmount}');

      // Update the amount for the selected requirement
      final updatedRequirements = state.selectedRequirements.map((req) {
        if (req.ingredientId == event.ingredientId) {
          return req.copyWith(requiredAmount: event.newAmount);
        }
        return req;
      }).toList();

      debugPrint(
          'Total requirements after updating: ${updatedRequirements.length}');

      // Hitung stock baru dan update state
      final newStock = await _calculateAndUpdateStock(
        updatedRequirements,
        state.availableIngredients,
      );

      emit(state.copyWith(
        selectedRequirements: updatedRequirements,
        stock: newStock,
      ));
    } catch (e) {
      debugPrint('Error updating ingredient amount: $e');
      emit(state.copyWith(error: 'Gagal mengubah jumlah bahan: $e'));
    }
  }

  Future<int> _calculateAndUpdateStock(
    List<MenuRequirementEntity> requirements,
    List<IngredientEntity> ingredients,
  ) async {
    try {
      // Gunakan UpdateMenuStockUseCase untuk menghitung stock
      // Tapi ini hanya simulasi untuk UI, belum disimpan ke database
      if (state.id.isEmpty || requirements.isEmpty) return 0;

      // Hanya untuk menghitung stock baru tanpa mengupdate ke Firestore
      final calculatedStock = await compute(
        (Map<String, dynamic> data) {
          final reqs = data['requirements'] as List<MenuRequirementEntity>;
          final ingrs = data['ingredients'] as List<IngredientEntity>;

          // Logic menghitung stock dari CalculateMenuStockUseCase
          if (reqs.isEmpty) return 0;

          final ingredientMap = {
            for (var ingredient in ingrs) ingredient.id: ingredient
          };

          List<int> possibleStocks = [];

          for (var requirement in reqs) {
            final ingredient = ingredientMap[requirement.ingredientId];

            if (ingredient == null || ingredient.stockAmount <= 0) {
              return 0;
            }

            final possibleStock =
                ingredient.stockAmount ~/ requirement.requiredAmount;

            if (possibleStock <= 0) {
              return 0;
            }

            possibleStocks.add(possibleStock);
          }

          return possibleStocks
              .reduce((min, stock) => stock < min ? stock : min);
        },
        {
          'requirements': requirements,
          'ingredients': ingredients,
        },
      );

      return calculatedStock;
    } catch (e) {
      debugPrint('Error calculating stock: $e');
      return 0;
    }
  }

  Future<void> _onSubmitEdit(
    SubmitEditEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      debugPrint('SubmitEdit: Updating menu with ID: ${state.id}');
      debugPrint('SubmitEdit: Menu name: ${state.name}');
      debugPrint('SubmitEdit: Menu price: ${state.price}');
      debugPrint(
          'SubmitEdit: Menu requirements count: ${state.selectedRequirements.length}');

      // Parse harga dari format currency
      final price = int.parse(state.price.replaceAll(RegExp(r'[^\d]'), ''));

      // Validasi data
      if (state.name.isEmpty) {
        throw Exception('Nama menu tidak boleh kosong');
      }
      if (price <= 0) {
        throw Exception('Harga menu harus lebih dari 0');
      }
      if (state.selectedRequirements.isEmpty) {
        throw Exception('Menu harus memiliki minimal 1 bahan');
      }

      // 1. Update menu
      await _updateMenuUseCase(
        id: state.id,
        name: state.name,
        price: price,
        imageFile: state.imagePath != null ? File(state.imagePath!) : null,
        currentImageUrl: state.imageUrl,
      );

      debugPrint('SubmitEdit: Menu updated successfully');

      // 2. Update menu requirements
      debugPrint('SubmitEdit: Updating menu requirements');
      await _updateMenuRequirementsUseCase(
        menuId: state.id,
        requirements: state.selectedRequirements,
      );

      debugPrint('SubmitEdit: Menu requirements updated successfully');

      // 3. Update menu stock berdasarkan requirements baru
      debugPrint('SubmitEdit: Updating menu stock');
      await _updateMenuStockUseCase(
        menuId: state.id,
        menuRequirements: state.selectedRequirements,
        availableIngredients: state.availableIngredients,
      );

      debugPrint('SubmitEdit: Menu stock updated successfully');

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      ));
    } catch (e) {
      debugPrint('SubmitEdit Error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memperbarui menu: $e',
      ));
    }
  }

  Future<void> _onDeleteMenu(
    DeleteMenuEvent event,
    Emitter<EditMenuState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      debugPrint('SubmitEdit: Deleting menu with ID: ${state.id}');

      await _deleteMenuUseCase(state.id);

      debugPrint('SubmitEdit: Menu deleted successfully');

      emit(state.copyWith(
        isLoading: false,
        isDeleted: true,
      ));
    } catch (e) {
      debugPrint('SubmitEdit Error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal menghapus menu: $e',
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
