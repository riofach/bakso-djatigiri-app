// BLoC untuk fitur stock management
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/ingredient_entity.dart';
import '../domain/usecases/delete_ingredient_usecase.dart';
import '../domain/usecases/get_ingredients_usecase.dart';
import '../../../features/menu/domain/usecases/update_all_menu_stocks_usecase.dart';

// Event
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class LoadStocksEvent extends StockEvent {}

class SearchStocksEvent extends StockEvent {
  final String query;

  const SearchStocksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteStockEvent extends StockEvent {
  final String id;

  const DeleteStockEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// State
abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<IngredientEntity> ingredients;
  final String searchQuery;

  const StockLoaded({required this.ingredients, this.searchQuery = ''});

  List<IngredientEntity> get filteredIngredients => searchQuery.isEmpty
      ? ingredients
      : ingredients
          .where(
            (ingredient) => ingredient.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();

  @override
  List<Object?> get props => [ingredients, searchQuery];

  StockLoaded copyWith({
    List<IngredientEntity>? ingredients,
    String? searchQuery,
  }) {
    return StockLoaded(
      ingredients: ingredients ?? this.ingredients,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class StockBloc extends Bloc<StockEvent, StockState> {
  final GetIngredientsUseCase _getIngredientsUseCase;
  final DeleteIngredientUseCase _deleteIngredientUseCase;
  final UpdateAllMenuStocksUseCase _updateAllMenuStocksUseCase;

  StockBloc(
    this._getIngredientsUseCase,
    this._deleteIngredientUseCase,
    this._updateAllMenuStocksUseCase,
  ) : super(StockInitial()) {
    on<LoadStocksEvent>(_onLoadStocks);
    on<SearchStocksEvent>(_onSearchStocks);
    on<DeleteStockEvent>(_onDeleteStock);
  }

  Future<void> _onLoadStocks(
    LoadStocksEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    try {
      final ingredients = await _getIngredientsUseCase();
      emit(StockLoaded(ingredients: ingredients));
    } catch (e) {
      emit(StockError('Gagal memuat data stock: $e'));
    }
  }

  void _onSearchStocks(SearchStocksEvent event, Emitter<StockState> emit) {
    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onDeleteStock(
    DeleteStockEvent event,
    Emitter<StockState> emit,
  ) async {
    try {
      // Hapus bahan
      await _deleteIngredientUseCase(event.id);

      // Update UI terlebih dahulu
      if (state is StockLoaded) {
        final currentState = state as StockLoaded;
        final updatedIngredients = currentState.ingredients
            .where((ingredient) => ingredient.id != event.id)
            .toList();

        emit(currentState.copyWith(ingredients: updatedIngredients));
      }

      // Update stok semua menu yang mungkin menggunakan bahan ini
      final ingredients = await _getIngredientsUseCase();
      final updatedCount = await _updateAllMenuStocksUseCase(
        availableIngredients: ingredients,
      );

      debugPrint('Berhasil memperbarui stok $updatedCount menu');
    } catch (e) {
      debugPrint('Gagal menghapus stock: $e');
      emit(StockError('Gagal menghapus stock: $e'));
    }
  }
}
