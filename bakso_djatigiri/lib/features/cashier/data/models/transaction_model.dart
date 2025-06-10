// Model class untuk transaksi (data layer)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String transactionCode;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final int total;
  final int customerPayment;
  final int change;

  const TransactionModel({
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
        change
      ];

  // Membuat objek dari Firestore DocumentSnapshot
  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      transactionCode: data['transaction_code'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cashierId: data['cashier_id'] ?? '',
      cashierName: data['cashier_name'] ?? '',
      total: data['total'] ?? 0,
      customerPayment: data['customer_payment'] ?? 0,
      change: data['change'] ?? 0,
    );
  }

  // Mengkonversi objek ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'transaction_code': transactionCode,
      'timestamp': FieldValue.serverTimestamp(),
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total': total,
      'customer_payment': customerPayment,
      'change': change,
    };
  }
}
