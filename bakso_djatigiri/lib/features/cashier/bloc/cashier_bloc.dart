// Bloc untuk fitur cashier
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../menu/domain/entities/menu_entity.dart';
import '../data/models/transaction_item_model.dart';
import '../domain/usecases/checkout_usecase.dart';
import '../domain/usecases/get_menus_usecase.dart';

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

class RemoveFromCartEvent extends CashierEvent {
  final int index;

  RemoveFromCartEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CheckoutEvent extends CashierEvent {
  final int payment;

  CheckoutEvent({
    required this.payment,
  });

  @override
  List<Object?> get props => [payment];
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
  final CheckoutUseCase _checkoutUseCase;
  final GetMenusUseCase _getMenusUseCase;

  CashierBloc({
    required CheckoutUseCase checkoutUseCase,
    required GetMenusUseCase getMenusUseCase,
  })  : _checkoutUseCase = checkoutUseCase,
        _getMenusUseCase = getMenusUseCase,
        super(CashierInitial()) {
    on<LoadMenusEvent>(_onLoadMenus);
    on<SearchMenusEvent>(_onSearchMenus);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<CheckoutEvent>(_onCheckout);
  }

  Future<void> _onLoadMenus(
    LoadMenusEvent event,
    Emitter<CashierState> emit,
  ) async {
    try {
      emit(CashierLoading());

      // Menggunakan GetMenusUseCase untuk mendapatkan daftar menu
      final result = await _getMenusUseCase();

      result.fold(
        (failure) {
          debugPrint('CashierBloc: Error loading menus: ${failure.message}');
          emit(CashierError(failure.message));
        },
        (menus) {
          // Filter menu yang stocknya > 0
          final availableMenus = menus.where((menu) => menu.stock > 0).toList();

          // Log detail menu untuk debugging
          debugPrint(
              'CashierBloc: Loaded ${availableMenus.length} available menus');
          for (var menu in availableMenus) {
            debugPrint(
                'CashierBloc: Menu ${menu.name} (ID: ${menu.id}) - Stock: ${menu.stock}');
          }

          emit(CashierLoaded(menus: availableMenus));
        },
      );
    } catch (e) {
      debugPrint('CashierBloc: Error loading menus: $e');
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

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = List<MenuEntity>.from(currentState.cartItems);

      if (event.index >= 0 && event.index < cartItems.length) {
        cartItems.removeAt(event.index);
        emit(currentState.copyWith(cartItems: cartItems));
      }
    }
  }

  Future<void> _onCheckout(
    CheckoutEvent event,
    Emitter<CashierState> emit,
  ) async {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = currentState.cartItems;

      if (cartItems.isEmpty) {
        return;
      }

      try {
        // Simpan jumlah cart items untuk debugging
        final numCartItems = cartItems.length;
        debugPrint('CashierBloc: Memulai checkout dengan $numCartItems item');

        // Konversi cartItems dari MenuEntity menjadi TransactionItemModel
        final transactionItems = cartItems.map((menu) {
          return TransactionItemModel(
            menuId: menu.id,
            menuName: menu.name,
            quantity: 1, // Default 1 untuk saat ini
            priceEach: menu.price,
            subtotal: menu.price,
          );
        }).toList();

        // Menggunakan use case untuk proses checkout
        await _checkoutUseCase(
          items: transactionItems,
          payment: event.payment,
        );

        // Clear cart terlebih dahulu
        emit(currentState.copyWith(cartItems: []));

        // Tambahkan delay kecil untuk memastikan Firestore sudah diupdate
        await Future.delayed(const Duration(milliseconds: 300));

        // Segera load menu untuk mendapatkan stok terbaru
        debugPrint('CashierBloc: Memuat ulang menu setelah checkout...');

        try {
          // Menggunakan GetMenusUseCase untuk mendapatkan menu yang updated
          final result = await _getMenusUseCase();

          result.fold(
            (failure) {
              debugPrint(
                  'CashierBloc: Error refreshing menus after checkout: ${failure.message}');
              // Tetap emit state dengan cart kosong meskipun refresh menu gagal
              emit(currentState.copyWith(cartItems: []));
            },
            (updatedMenus) {
              // Filter menu yang stocknya > 0
              final availableMenus =
                  updatedMenus.where((menu) => menu.stock > 0).toList();

              debugPrint(
                  'CashierBloc: Menu berhasil dimuat ulang - ${availableMenus.length} menu tersedia');

              // Log detail menu yang tersedia untuk debugging
              for (var menu in availableMenus) {
                debugPrint(
                    'CashierBloc: Menu ${menu.name} (ID: ${menu.id}) - stok: ${menu.stock}');
              }

              // Emit updated state dengan menu yang diperbarui
              emit(CashierLoaded(
                menus: updatedMenus,
                filteredMenus: availableMenus,
                cartItems: [],
              ));

              debugPrint('CashierBloc: Checkout selesai, UI sudah diperbarui');
            },
          );
        } catch (e) {
          debugPrint('CashierBloc: Error refreshing menus after checkout: $e');
          // Tetap emit state dengan cart kosong meskipun refresh menu gagal
          emit(currentState.copyWith(cartItems: []));
        }
      } catch (e) {
        debugPrint('CashierBloc: Error during checkout: $e');
        emit(CashierError('Gagal melakukan checkout: $e'));
      }
    }
  }
}
