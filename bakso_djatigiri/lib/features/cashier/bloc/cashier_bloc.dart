// Bloc untuk fitur cashier
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../menu/domain/entities/menu_entity.dart';

// Events
abstract class CashierEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMenusEvent extends CashierEvent {}

class SearchMenusEvent extends CashierEvent {
  final String query;

  SearchMenusEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddToCartEvent extends CashierEvent {
  final MenuEntity menu;

  AddToCartEvent(this.menu);

  @override
  List<Object?> get props => [menu];
}

// States
abstract class CashierState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CashierInitial extends CashierState {}

class CashierLoading extends CashierState {}

class CashierLoaded extends CashierState {
  final List<MenuEntity> menus;
  final List<MenuEntity> filteredMenus;
  final List<MenuEntity> cartItems;

  CashierLoaded({
    required this.menus,
    List<MenuEntity>? filteredMenus,
    this.cartItems = const [],
  }) : filteredMenus = filteredMenus ?? menus;

  CashierLoaded copyWith({
    List<MenuEntity>? menus,
    List<MenuEntity>? filteredMenus,
    List<MenuEntity>? cartItems,
  }) {
    return CashierLoaded(
      menus: menus ?? this.menus,
      filteredMenus: filteredMenus ?? this.filteredMenus,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  @override
  List<Object?> get props => [menus, filteredMenus, cartItems];
}

class CashierError extends CashierState {
  final String message;

  CashierError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class CashierBloc extends Bloc<CashierEvent, CashierState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CashierBloc() : super(CashierInitial()) {
    on<LoadMenusEvent>(_onLoadMenus);
    on<SearchMenusEvent>(_onSearchMenus);
    on<AddToCartEvent>(_onAddToCart);
  }

  Future<void> _onLoadMenus(
    LoadMenusEvent event,
    Emitter<CashierState> emit,
  ) async {
    try {
      emit(CashierLoading());

      // Mengambil data menu dari Firestore
      final snapshot = await _firestore
          .collection('menus')
          .orderBy('created_at', descending: false)
          .get();

      final menus = snapshot.docs.map((doc) {
        final data = doc.data();
        return MenuEntity(
          id: doc.id,
          name: data['name'] ?? '',
          price: data['price'] ?? 0,
          stock: data['stock'] ?? 0,
          imageUrl: data['image_url'] ?? '',
          createdAt:
              (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      // Filter menu yang stocknya > 0
      final availableMenus = menus.where((menu) => menu.stock > 0).toList();

      emit(CashierLoaded(menus: availableMenus));
    } catch (e) {
      debugPrint('Error loading menus: $e');
      emit(CashierError('Gagal memuat menu: $e'));
    }
  }

  void _onSearchMenus(
    SearchMenusEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(filteredMenus: currentState.menus));
        return;
      }

      final filteredMenus = currentState.menus
          .where((menu) => menu.name.toLowerCase().contains(query))
          .toList();

      emit(currentState.copyWith(filteredMenus: filteredMenus));
    }
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = List<MenuEntity>.from(currentState.cartItems)
        ..add(event.menu);

      emit(currentState.copyWith(cartItems: cartItems));
    }
  }
}
