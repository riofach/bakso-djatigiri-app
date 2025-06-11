// Entity untuk Transaction
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String transactionCode;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final int total;
  final int customerPayment;
  final int change;

  const Transaction({
    required this.id,
    required this.transactionCode,
    required this.timestamp,
    required this.cashierId,
    required this.cashierName,
    required this.total,
    required this.customerPayment,
    required this.change,
  });

  @override
  List<Object?> get props => [
        id,
        transactionCode,
        timestamp,
        cashierId,
        cashierName,
        total,
        customerPayment,
        change,
      ];
}
