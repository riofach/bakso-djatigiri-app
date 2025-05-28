// BLoC untuk fitur stock management
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Model
class IngredientModel extends Equatable {
  final String id;
  final String name;
  final int stockAmount;
  final String imageUrl;
  final DateTime createdAt;

  const IngredientModel({
    required this.id,
    required this.name,
    required this.stockAmount,
    required this.imageUrl,
    required this.createdAt,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map, String id) {
    return IngredientModel(
      id: id,
      name: map['name'] ?? '',
      stockAmount: map['stock_amount'] ?? 0,
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, stockAmount, imageUrl, createdAt];
}

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
  final List<IngredientModel> ingredients;
  final String searchQuery;

  const StockLoaded({required this.ingredients, this.searchQuery = ''});

  List<IngredientModel> get filteredIngredients => searchQuery.isEmpty
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
    List<IngredientModel>? ingredients,
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
class StockBloc extends Bloc<StockEvent, StockState> {
  final FirebaseFirestore _firestore;

  StockBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(StockInitial()) {
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
      final snapshot = await _firestore
          .collection('ingredients')
          .orderBy('created_at', descending: false)
          .get();

      final ingredients = snapshot.docs
          .map((doc) => IngredientModel.fromMap(doc.data(), doc.id))
          .toList();

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
      await _firestore.collection('ingredients').doc(event.id).delete();

      if (state is StockLoaded) {
        final currentState = state as StockLoaded;
        final updatedIngredients = currentState.ingredients
            .where((ingredient) => ingredient.id != event.id)
            .toList();

        emit(currentState.copyWith(ingredients: updatedIngredients));
      }
    } catch (e) {
      emit(StockError('Gagal menghapus stock: $e'));
    }
  }
}
