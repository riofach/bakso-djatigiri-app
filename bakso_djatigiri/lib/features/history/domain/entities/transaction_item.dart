// Entity untuk TransactionItem
import 'package:equatable/equatable.dart';

class TransactionItem extends Equatable {
  final String id;
  final String transactionId;
  final String menuId;
  final String menuName;
  final int quantity;
  final int priceEach;
  final int subtotal;

  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.priceEach,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        transactionId,
        menuId,
        menuName,
        quantity,
        priceEach,
        subtotal,
      ];
}
