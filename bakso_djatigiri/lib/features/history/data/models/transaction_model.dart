// Model untuk Transaction di data layer
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as entity;

class TransactionModel extends entity.Transaction {
  const TransactionModel({
    required super.id,
    required super.transactionCode,
    required super.timestamp,
    required super.cashierId,
    required super.cashierName,
    required super.total,
    required super.customerPayment,
    required super.change,
  });

  // Factory untuk membuat model dari Firestore DocumentSnapshot
  factory TransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return TransactionModel(
      id: snapshot.id,
      transactionCode: data['transaction_code'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      cashierId: data['cashier_id'] ?? '',
      cashierName: data['cashier_name'] ?? '',
      total: data['total'] ?? 0,
      customerPayment: data['customer_payment'] ?? 0,
      change: data['change'] ?? 0,
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'transaction_code': transactionCode,
      'timestamp': Timestamp.fromDate(timestamp),
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total': total,
      'customer_payment': customerPayment,
      'change': change,
    };
  }
}
