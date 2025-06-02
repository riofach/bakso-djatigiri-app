// BLoC untuk fitur menu management
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Model
class MenuModel extends Equatable {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final DateTime createdAt;

  const MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.createdAt,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      id: id,
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, price, stock, imageUrl, createdAt];
}

// Event
abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenusEvent extends MenuEvent {}

class SearchMenusEvent extends MenuEvent {
  final String query;

  const SearchMenusEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// State
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuModel> menus;
  final String searchQuery;

  const MenuLoaded({required this.menus, this.searchQuery = ''});

  List<MenuModel> get filteredMenus => searchQuery.isEmpty
      ? menus
      : menus
          .where(
            (menu) => menu.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();

  @override
  List<Object?> get props => [menus, searchQuery];

  MenuLoaded copyWith({
    List<MenuModel>? menus,
    String? searchQuery,
  }) {
    return MenuLoaded(
      menus: menus ?? this.menus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final FirebaseFirestore _firestore;

  MenuBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(MenuInitial()) {
    on<LoadMenusEvent>(_onLoadMenus);
    on<SearchMenusEvent>(_onSearchMenus);
  }

  Future<void> _onLoadMenus(
    LoadMenusEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());
    try {
      final snapshot = await _firestore
          .collection('menus')
          .orderBy('created_at', descending: false)
          .get();

      final menus = snapshot.docs
          .map((doc) => MenuModel.fromMap(doc.data(), doc.id))
          .toList();

      emit(MenuLoaded(menus: menus));
    } catch (e) {
      emit(MenuError('Gagal memuat data menu: $e'));
    }
  }

  void _onSearchMenus(SearchMenusEvent event, Emitter<MenuState> emit) {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }
}
