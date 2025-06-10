// Bloc untuk fitur cashier
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../menu/domain/entities/menu_entity.dart';
import '../data/models/transaction_item_model.dart';
import '../domain/usecases/checkout_usecase.dart';
import '../domain/usecases/get_menus_usecase.dart';
import '../domain/usecases/create_stock_warning_notification_usecase.dart';

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

class IncreaseCartItemQuantityEvent extends CashierEvent {
  final int index;

  IncreaseCartItemQuantityEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class DecreaseCartItemQuantityEvent extends CashierEvent {
  final int index;

  DecreaseCartItemQuantityEvent(this.index);

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
  final List<CartItem> cartItems;
  final String? message;
  final int? lastTransactionTotal;
  final int? lastTransactionPayment;

  CashierLoaded({
    required this.menus,
    List<MenuEntity>? filteredMenus,
    this.cartItems = const [],
    this.message,
    this.lastTransactionTotal,
    this.lastTransactionPayment,
  }) : filteredMenus = filteredMenus ?? menus;

  CashierLoaded copyWith({
    List<MenuEntity>? menus,
    List<MenuEntity>? filteredMenus,
    List<CartItem>? cartItems,
    String? message,
    int? lastTransactionTotal,
    int? lastTransactionPayment,
    bool clearMessage = false,
  }) {
    return CashierLoaded(
      menus: menus ?? this.menus,
      filteredMenus: filteredMenus ?? this.filteredMenus,
      cartItems: cartItems ?? this.cartItems,
      message: clearMessage ? null : message ?? this.message,
      lastTransactionTotal: lastTransactionTotal ?? this.lastTransactionTotal,
      lastTransactionPayment:
          lastTransactionPayment ?? this.lastTransactionPayment,
    );
  }

  @override
  List<Object?> get props => [
        menus,
        filteredMenus,
        cartItems,
        message,
        lastTransactionTotal,
        lastTransactionPayment
      ];
}

class CashierError extends CashierState {
  final String message;

  CashierError(this.message);

  @override
  List<Object?> get props => [message];
}

// Model untuk item keranjang dengan quantity
class CartItem extends Equatable {
  final MenuEntity menu;
  final int quantity;

  const CartItem({
    required this.menu,
    this.quantity = 1,
  });

  CartItem copyWith({
    MenuEntity? menu,
    int? quantity,
  }) {
    return CartItem(
      menu: menu ?? this.menu,
      quantity: quantity ?? this.quantity,
    );
  }

  int get price => menu.price * quantity;

  @override
  List<Object?> get props => [menu, quantity];
}

// Bloc
@injectable
class CashierBloc extends Bloc<CashierEvent, CashierState> {
  final CheckoutUseCase _checkoutUseCase;
  final GetMenusUseCase _getMenusUseCase;
  final CreateStockWarningNotificationUseCase?
      _createStockWarningNotificationUseCase;

  CashierBloc({
    required CheckoutUseCase checkoutUseCase,
    required GetMenusUseCase getMenusUseCase,
    CreateStockWarningNotificationUseCase?
        createStockWarningNotificationUseCase,
  })  : _checkoutUseCase = checkoutUseCase,
        _getMenusUseCase = getMenusUseCase,
        _createStockWarningNotificationUseCase =
            createStockWarningNotificationUseCase,
        super(CashierInitial()) {
    on<LoadMenusEvent>(_onLoadMenus);
    on<SearchMenusEvent>(_onSearchMenus);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<IncreaseCartItemQuantityEvent>(_onIncreaseCartItemQuantity);
    on<DecreaseCartItemQuantityEvent>(_onDecreaseCartItemQuantity);
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

            // Cek apakah stok rendah (≤ 5) dan buat notifikasi jika perlu
            if (menu.stock <= 5) {
              _createStockWarningNotification(menu.name, menu.stock);
            }
          }

          // Pertahankan keranjang jika sebelumnya sudah ada
          final List<CartItem> currentCart = [];
          if (state is CashierLoaded) {
            currentCart.addAll((state as CashierLoaded).cartItems);
          }

          emit(CashierLoaded(
              menus: availableMenus,
              cartItems: currentCart,
              lastTransactionTotal: null,
              lastTransactionPayment: null));
        },
      );
    } catch (e) {
      debugPrint('CashierBloc: Error loading menus: $e');
      emit(CashierError('Gagal memuat menu: $e'));
    }
  }

  // Fungsi untuk membuat notifikasi peringatan stok rendah
  void _createStockWarningNotification(String menuName, int stock) {
    if (_createStockWarningNotificationUseCase != null) {
      debugPrint(
          'CashierBloc: Mencoba membuat notifikasi stok rendah untuk $menuName (stok: $stock)');
      _createStockWarningNotificationUseCase(
        menuName: menuName,
        stock: stock,
      ).then((result) {
        result.fold(
          (failure) {
            debugPrint(
                'CashierBloc: Error creating stock warning notification: ${failure.message}');
          },
          (_) {
            debugPrint(
                'CashierBloc: Stock warning notification created/checked for $menuName (stock: $stock)');
          },
        );
      });
    } else {
      debugPrint('CashierBloc: CreateStockWarningNotificationUseCase is null');
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
      final cartItems = List<CartItem>.from(currentState.cartItems);

      // Cari apakah menu sudah ada di keranjang
      final existingIndex =
          cartItems.indexWhere((item) => item.menu.id == event.menu.id);

      if (existingIndex >= 0) {
        // Jika sudah ada, tambah quantity
        final existingItem = cartItems[existingIndex];

        // Validasi stok tersedia
        if (existingItem.quantity >= event.menu.stock) {
          // Stok tidak mencukupi
          emit(currentState.copyWith(
              message:
                  'Stok ${event.menu.name} tidak mencukupi (${event.menu.stock} tersisa)'));
          return;
        }

        cartItems[existingIndex] =
            existingItem.copyWith(quantity: existingItem.quantity + 1);
      } else {
        // Jika belum ada, tambahkan sebagai item baru
        cartItems.add(CartItem(menu: event.menu, quantity: 1));
      }

      emit(currentState.copyWith(cartItems: cartItems));
    }
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = List<CartItem>.from(currentState.cartItems);

      if (event.index >= 0 && event.index < cartItems.length) {
        cartItems.removeAt(event.index);
        emit(currentState.copyWith(cartItems: cartItems));
      }
    }
  }

  void _onIncreaseCartItemQuantity(
    IncreaseCartItemQuantityEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = List<CartItem>.from(currentState.cartItems);

      if (event.index >= 0 && event.index < cartItems.length) {
        final item = cartItems[event.index];

        // Validasi stok tersedia
        if (item.quantity >= item.menu.stock) {
          // Stok tidak mencukupi
          emit(currentState.copyWith(
              message:
                  'Stok ${item.menu.name} tidak mencukupi (${item.menu.stock} tersisa)'));
          return;
        }

        cartItems[event.index] = item.copyWith(quantity: item.quantity + 1);
        emit(currentState.copyWith(cartItems: cartItems));
      }
    }
  }

  void _onDecreaseCartItemQuantity(
    DecreaseCartItemQuantityEvent event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      final cartItems = List<CartItem>.from(currentState.cartItems);

      if (event.index >= 0 && event.index < cartItems.length) {
        final item = cartItems[event.index];
        if (item.quantity > 1) {
          // Jika quantity > 1, kurangi quantity
          cartItems[event.index] = item.copyWith(quantity: item.quantity - 1);
          emit(currentState.copyWith(cartItems: cartItems));
        } else {
          // Jika quantity = 1, hapus item dari keranjang
          cartItems.removeAt(event.index);
          emit(currentState.copyWith(cartItems: cartItems));
        }
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

        // Hitung total harga
        final totalPrice = cartItems.fold<int>(
          0,
          (sum, item) => sum + item.price,
        );

        // Konversi cartItems dari CartItem menjadi TransactionItemModel
        final transactionItems = cartItems.map((item) {
          return TransactionItemModel(
            menuId: item.menu.id,
            menuName: item.menu.name,
            quantity: item.quantity, // Gunakan quantity dari CartItem
            priceEach: item.menu.price,
            subtotal: item.menu.price *
                item.quantity, // Hitung subtotal berdasarkan quantity
          );
        }).toList();

        // Menggunakan use case untuk proses checkout
        await _checkoutUseCase(
          items: transactionItems,
          payment: event.payment,
        );

        // Clear cart terlebih dahulu dan simpan data transaksi terakhir
        emit(currentState.copyWith(
          cartItems: [],
          lastTransactionTotal: totalPrice,
          lastTransactionPayment: event.payment,
        ));

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
              emit(currentState.copyWith(
                cartItems: [],
                lastTransactionTotal: totalPrice,
                lastTransactionPayment: event.payment,
              ));
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

                // Cek apakah stok rendah (≤ 5) dan buat notifikasi jika perlu
                if (menu.stock <= 5) {
                  _createStockWarningNotification(menu.name, menu.stock);
                }
              }

              // Emit updated state dengan menu yang diperbarui
              emit(CashierLoaded(
                menus: updatedMenus,
                filteredMenus: availableMenus,
                cartItems: [],
                lastTransactionTotal: totalPrice,
                lastTransactionPayment: event.payment,
              ));

              debugPrint('CashierBloc: Checkout selesai, UI sudah diperbarui');
            },
          );
        } catch (e) {
          debugPrint('CashierBloc: Error refreshing menus after checkout: $e');
          // Tetap emit state dengan cart kosong meskipun refresh menu gagal
          emit(currentState.copyWith(
            cartItems: [],
            lastTransactionTotal: totalPrice,
            lastTransactionPayment: event.payment,
          ));
        }
      } catch (e) {
        debugPrint('CashierBloc: Error during checkout: $e');
        emit(CashierError('Gagal melakukan checkout: $e'));
      }
    }
  }
}
