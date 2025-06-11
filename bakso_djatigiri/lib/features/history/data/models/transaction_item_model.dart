// Model untuk TransactionItem di data layer
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    required super.id,
    required super.transactionId,
    required super.menuId,
    required super.menuName,
    required super.quantity,
    required super.priceEach,
    required super.subtotal,
  });

  // Factory untuk membuat model dari Firestore DocumentSnapshot
  factory TransactionItemModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return TransactionItemModel(
      id: snapshot.id,
      transactionId: data['transaction_id'] ?? '',
      menuId: data['menu_id'] ?? '',
      menuName: data['menu_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      priceEach: data['price_each'] ?? 0,
      subtotal: data['subtotal'] ?? 0,
    );
  }

  // Konversi ke Map untuk Firestore
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
}
