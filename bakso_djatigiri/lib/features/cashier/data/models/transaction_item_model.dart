// Model class untuk item transaksi (data layer)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/menu_entity.dart';

class TransactionItemModel extends Equatable {
  final String id;
  final String transactionId;
  final String menuId;
  final String menuName;
  final int quantity;
  final int priceEach;
  final int subtotal;

  const TransactionItemModel({
    this.id = '',
    this.transactionId = '',
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.priceEach,
    required this.subtotal,
  });

  @override
  List<Object?> get props =>
      [id, transactionId, menuId, menuName, quantity, priceEach, subtotal];

  // Membuat objek dari Firestore DocumentSnapshot
  factory TransactionItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionItemModel(
      id: doc.id,
      transactionId: data['transaction_id'] ?? '',
      menuId: data['menu_id'] ?? '',
      menuName: data['menu_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      priceEach: data['price_each'] ?? 0,
      subtotal: data['subtotal'] ?? 0,
    );
  }

  // Mengkonversi objek ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'menu_id': menuId,
      'menu_name': menuName,
      'quantity': quantity,
      'price_each': priceEach,
      'subtotal': subtotal,
    };
  }

  // Metode factory untuk membuat dari MenuEntity
  factory TransactionItemModel.fromMenuEntity(MenuEntity menu) {
    return TransactionItemModel(
      menuId: menu.id,
      menuName: menu.name,
      quantity: 1,
      priceEach: menu.price,
      subtotal: menu.price,
    );
  }
}
