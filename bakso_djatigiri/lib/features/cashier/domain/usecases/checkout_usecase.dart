// Use case untuk checkout
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/transaction_item_model.dart';
import './reduce_ingredients_stock_usecase.dart';

@injectable
class CheckoutUseCase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ReduceIngredientsStockUseCase _reduceIngredientsStockUseCase;

  CheckoutUseCase({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required ReduceIngredientsStockUseCase reduceIngredientsStockUseCase,
  })  : _firestore = firestore,
        _auth = auth,
        _reduceIngredientsStockUseCase = reduceIngredientsStockUseCase;

  Future<String> call({
    required List<TransactionItemModel> items,
    required int payment,
  }) async {
    try {
      if (items.isEmpty) {
        throw Exception('Keranjang kosong');
      }

      debugPrint(
          'CheckoutUseCase: Memulai proses checkout dengan ${items.length} item');

      // Validasi pembayaran
      final totalPrice = items.fold<int>(
        0,
        (sum, item) => sum + item.subtotal,
      );

      debugPrint(
          'CheckoutUseCase: Total harga: $totalPrice, Pembayaran: $payment');

      if (payment < totalPrice) {
        throw Exception('Pembayaran kurang dari total harga');
      }

      // Mendapatkan user saat ini
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi. Silakan login kembali.');
      }

      // Mendapatkan data user dari Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('Data user tidak ditemukan.');
      }

      final userData = userDoc.data();
      final cashierName = userData?['name'] ?? 'Kasir';

      debugPrint(
          'CheckoutUseCase: User terautentikasi: ${currentUser.uid}, Nama: $cashierName');

      // Generate transaction code
      final transactionCode = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('CheckoutUseCase: Kode transaksi: $transactionCode');

      // Create transaction document
      final transactionRef = await _firestore.collection('transactions').add({
        'transaction_code': transactionCode,
        'timestamp': FieldValue.serverTimestamp(),
        'cashier_id': currentUser.uid,
        'cashier_name': cashierName,
        'total': totalPrice,
        'customer_payment': payment,
        'change': payment - totalPrice,
      });

      debugPrint(
          'CheckoutUseCase: Transaction document dibuat dengan ID: ${transactionRef.id}');

      // Add transaction items
      debugPrint(
          'CheckoutUseCase: Menambahkan ${items.length} item transaksi...');
      final batch = _firestore.batch();

      for (var item in items) {
        final itemRef = _firestore.collection('transaction_items').doc();
        batch.set(itemRef, {
          'transaction_id': transactionRef.id,
          'menu_id': item.menuId,
          'menu_name': item.menuName,
          'quantity': item.quantity,
          'price_each': item.priceEach,
          'subtotal': item.subtotal,
        });
        debugPrint(
            'CheckoutUseCase: Item ${item.menuName} ditambahkan ke batch');
      }

      // Commit transaction items batch
      await batch.commit();
      debugPrint('CheckoutUseCase: Semua item transaksi berhasil ditambahkan');

      // Mengurangi stok bahan dan menu berdasarkan pesanan
      debugPrint('CheckoutUseCase: Mulai mengurangi stok bahan dan menu...');
      await _reduceIngredientsStockUseCase(items);
      debugPrint('CheckoutUseCase: Stok bahan dan menu berhasil diperbarui');

      debugPrint('CheckoutUseCase: Checkout berhasil: $transactionCode');
      return transactionCode;
    } catch (e) {
      debugPrint('CheckoutUseCase: Error during checkout: $e');
      throw Exception('Gagal melakukan checkout: $e');
    }
  }
}
